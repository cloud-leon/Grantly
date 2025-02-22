import 'package:flutter/material.dart';
import '../utils/country_codes.dart';

class PhoneInputWidget extends StatefulWidget {
  final Function(String) onPhoneChanged;
  final Function(CountryCode) onCountryChanged;
  final String initialCountryCode;

  const PhoneInputWidget({
    super.key,
    required this.onPhoneChanged,
    required this.onCountryChanged,
    this.initialCountryCode = 'US',
  });

  @override
  State<PhoneInputWidget> createState() => _PhoneInputWidgetState();
}

class _PhoneInputWidgetState extends State<PhoneInputWidget> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  late CountryCode _selectedCountry;
  List<CountryCode> _filteredCountries = CountryCodes.countries;

  @override
  void initState() {
    super.initState();
    _selectedCountry = CountryCodes.getByShortName(widget.initialCountryCode);
    _searchController.addListener(_filterCountries);
  }

  void _filterCountries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCountries = CountryCodes.countries.where((country) {
        return country.name.toLowerCase().contains(query) ||
            country.code.toLowerCase().contains(query) ||
            country.shortName.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Country',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search country',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF7B4DFF)),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (value) {
                    setState(() {
                      _filterCountries();
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredCountries.length,
                  itemBuilder: (context, index) {
                    final country = _filteredCountries[index];
                    return ListTile(
                      leading: Text(
                        country.flag,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(country.name),
                      trailing: Text(
                        country.code,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      onTap: () {
                        this.setState(() => _selectedCountry = country);
                        widget.onCountryChanged(country);
                        _searchController.clear();
                        _filterCountries();
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My number is',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country code selector
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 1),
                ),
              ),
              child: TextButton(
                onPressed: _showCountryPicker,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedCountry.flag,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedCountry.code,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.black),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Phone number input
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                  hintText: '000000000',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: UnderlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                onChanged: widget.onPhoneChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _searchController.dispose();
    super.dispose();
  }
} 