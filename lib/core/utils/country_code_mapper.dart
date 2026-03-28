class CountryCodeMapper {
  /// Returns the ISO country code for a given country name.
  /// Used by the country_flags package.
  static String getIsoCode(String countryName) {
    // Normaliza para facilitar a busca (lowercase e remove espaços no final)
    final name = countryName.trim().toLowerCase();

    switch (name) {
      case 'argentina':
        return 'AR';
      case 'armenia':
        return 'AM';
      case 'austria':
        return 'AT';
      case 'belgium':
        return 'BE';
      case 'brazil':
        return 'BR';
      case 'cameroon':
        return 'CM';
      case 'canada':
        return 'CA';
      case 'colombia':
        return 'CO';
      case 'croatia':
        return 'HR';
      case 'czech republic':
        return 'CZ';
      case 'denmark':
        return 'DK';
      case 'ecuador':
        return 'EC';
      case 'egypt':
        return 'EG';
      case 'england':
        return 'GB-ENG'; // Inglaterra tem bandeira própria no pacote
      case 'france':
        return 'FR';
      case 'gabon':
        return 'GA';
      case 'germany':
        return 'DE';
      case 'ghana':
        return 'GH';
      case 'guinea':
        return 'GN';
      case 'ireland':
        return 'IE';
      case 'italy':
        return 'IT';
      case 'ivory coast':
        return 'CI';
      case 'jamaica':
        return 'JM';
      case 'japan':
        return 'JP';
      case 'korea republic':
      case 'south korea':
        return 'KR';
      case 'morocco':
        return 'MA';
      case 'netherlands':
        return 'NL';
      case 'new zealand':
        return 'NZ';
      case 'nigeria':
        return 'NG';
      case 'norway':
        return 'NO';
      case 'poland':
        return 'PL';
      case 'portugal':
        return 'PT';
      case 'russia':
        return 'RU';
      case 'senegal':
        return 'SN';
      case 'serbia':
        return 'RS';
      case 'slovakia':
        return 'SK';
      case 'slovenia':
        return 'SI';
      case 'spain':
        return 'ES';
      case 'sweden':
        return 'SE';
      case 'switzerland':
        return 'CH';
      case 'turkey':
      case 'turkiye':
        return 'TR';
      case 'ukraine':
        return 'UA';
      case 'united states':
      case 'usa':
        return 'US';
      case 'uruguay':
        return 'UY';
      case 'wales':
        return 'GB-WLS'; 
      case 'scotland':
        return 'GB-SCT'; 
      case 'northern ireland':
        return 'GB-NIR'; 
      default:
        if (name.length >= 2) {
          return name.substring(0, 2).toUpperCase();
        }
        return 'UN'; // Unknown
    }
  }
}
