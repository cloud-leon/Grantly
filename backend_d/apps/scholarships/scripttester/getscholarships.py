import requests
from bs4 import BeautifulSoup
import csv
import time
import os
import json
from datetime import datetime

# Add this constant near the top of the file, after imports
CHECKPOINT_FILE = "scholarship_checkpoint.json"

BASE_URL = "https://www.careeronestop.org"

# Add these headers
HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.5',
    'Connection': 'keep-alive',
}

def load_checkpoint():
    if os.path.exists(CHECKPOINT_FILE):
        with open(CHECKPOINT_FILE, 'r') as f:
            return json.load(f)
    return {"last_page": 1, "processed_scholarships": []}

def save_checkpoint(page, scholarships):
    with open(CHECKPOINT_FILE, 'w') as f:
        json.dump({
            "last_page": page,
            "processed_scholarships": scholarships,
            "last_updated": datetime.now().isoformat()
        }, f)

def get_scholarships(start_page=None):
    # Load checkpoint if exists
    checkpoint = load_checkpoint()
    all_scholarships = checkpoint["processed_scholarships"]
    page = start_page or checkpoint["last_page"]
    total_pages = 20

    print(f"Starting from page {page} with {len(all_scholarships)} scholarships already processed")

    while page <= total_pages:
        try:
            url = f"{BASE_URL}/Toolkit/Training/find-scholarships.aspx?curpage={page}&pagesize=500&lang=en"
            print(f"Fetching page {page} of {total_pages}...")
            
            # Add headers to the request
            response = requests.get(url, headers=HEADERS, timeout=30)
            response.raise_for_status()  # Raise an exception for bad status codes
            soup = BeautifulSoup(response.text, 'html.parser')

            page_scholarships = []  # Track scholarships for current page

            # Iterate through each scholarship entry
            for row in soup.select("tr"):
                try:
                    link_tag = row.select_one("div.detailPageLink a")
                    if not link_tag:
                        continue

                    scholarship_name = link_tag.text.strip()
                    detail_link = BASE_URL + link_tag["href"]
                    
                    # Skip if we've already processed this scholarship
                    if any(s[0] == scholarship_name for s in all_scholarships):
                        print(f"Skipping already processed scholarship: {scholarship_name}")
                        continue

                    organization = row.select_one("div.notranslate").text.strip() if row.select_one("div.notranslate") else "N/A"
                    purpose_div = row.select("div")[-1] if row.select("div") else None
                    purpose = purpose_div.text.strip() if purpose_div else "N/A"
                    
                    level_of_study = row.select_one("td[data-label-es='Level Of Study'] div").text.strip().replace('<br />', ', ') if row.select_one("td[data-label-es='Level Of Study'] div") else "N/A"
                    award_type = row.select_one("td[data-label-es='Award Type'] div").text.strip().replace('<br />', ', ') if row.select_one("td[data-label-es='Award Type'] div") else "N/A"
                    award_amount = row.select_one("td[data-label-es='Award Amount'] div.table-Numeric").text.strip() if row.select_one("td[data-label-es='Award Amount'] div.table-Numeric") else "N/A"
                    deadline = row.select_one("td[data-label-es='Deadline']").text.strip() if row.select_one("td[data-label-es='Deadline']") else "N/A"

                    # Get more details with retry mechanism
                    max_retries = 3
                    for attempt in range(max_retries):
                        try:
                            details = get_scholarship_details(detail_link)
                            break
                        except Exception as e:
                            if attempt == max_retries - 1:
                                print(f"Failed to get details for {scholarship_name} after {max_retries} attempts: {str(e)}")
                                details = {}
                            else:
                                time.sleep(2 ** attempt)  # Exponential backoff

                    scholarship_data = [
                        scholarship_name, organization, purpose, 
                        level_of_study, award_type, award_amount, deadline,
                        details.get("Focus", "N/A"), details.get("Qualifications", "N/A"), details.get("Criteria", "N/A"),
                        details.get("Duration", "N/A"), details.get("Number of Awards", "N/A"),
                        details.get("To Apply", "N/A"), details.get("Contact", "N/A"), details.get("More Info", "N/A")
                    ]

                    page_scholarships.append(scholarship_data)
                    print(f"Processed: {scholarship_name}")
                    time.sleep(1)  # Delay between scholarships

                except Exception as e:
                    print(f"Error processing scholarship: {str(e)}")
                    continue

            # Add page scholarships to main list and save checkpoint
            all_scholarships.extend(page_scholarships)
            save_checkpoint(page, all_scholarships)
            
            page += 1
            time.sleep(2)  # Delay between pages

        except requests.exceptions.RequestException as e:
            print(f"Error fetching page {page}: {str(e)}")
            print("Retrying in 60 seconds...")
            time.sleep(60)
            continue
        except Exception as e:
            print(f"Unexpected error on page {page}: {str(e)}")
            print("Saving progress and exiting...")
            save_checkpoint(page, all_scholarships)
            raise

    # Clean up checkpoint file after successful completion
 
    return all_scholarships

def get_scholarship_details(url):
    # Add headers to this request as well
    response = requests.get(url, headers=HEADERS)
    soup = BeautifulSoup(response.text, 'html.parser')

    def extract_text(label):
        # Find the cell containing the label (case-insensitive)
        cell = soup.find("td", string=lambda text: text and text.strip() == label)
        if not cell:
            return "N/A"
        # Get the next cell (sibling) and its text
        next_cell = cell.find_next_sibling("td")
        return next_cell.text.strip() if next_cell else "N/A"

    return {
        "Focus": extract_text("Focus"),
        "Qualifications": extract_text("Qualifications"),
        "Criteria": extract_text("Criteria"),
        "Duration": extract_text("Duration"),
        "Number of Awards": extract_text("Number of Awards"),
        "To Apply": extract_text("To Apply"),
        "Contact": extract_text("Contact"),
        "More Info": extract_text("For more information"),
        # You might want to add these additional fields:
        "Organization": extract_text("Organization"),
        "Phone": extract_text("Phone Number"),
        "Email": extract_text("Emails"),
        "Purpose": extract_text("Purpose")
    }

def save_to_csv(scholarships, filename="scholarships.csv"):
    headers = [
        "Scholarship Name", "Organization", "Purpose", 
        "Level of Study", "Award Type", "Award Amount", "Deadline",
        "Focus", "Qualifications", "Criteria",
        "Duration", "Number of Awards",
        "To Apply", "Contact", "More Info"
    ]

    with open(filename, "w", newline="", encoding="utf-8") as file:
        writer = csv.writer(file)
        writer.writerow(headers)
        writer.writerows(scholarships)

if __name__ == "__main__":
    scholarships = get_scholarships()
    save_to_csv(scholarships)
    print("Data saved to scholarships.csv")
