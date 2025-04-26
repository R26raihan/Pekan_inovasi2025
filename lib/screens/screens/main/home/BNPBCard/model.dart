class Banjir {
  final String nprop;
  final String nkab;
  final String kejadian;
  final String tanggal;
  final String longitude;
  final String latitude;
  final String keterangan;
  final String penyebab;
  final String kronologis;

  Banjir({
    required this.nprop,
    required this.nkab,
    required this.kejadian,
    required this.tanggal,
    required this.longitude,
    required this.latitude,
    required this.keterangan,
    required this.penyebab,
    required this.kronologis,
  });

  factory Banjir.fromJson(Map<String, dynamic> json) {
    return Banjir(
      nprop: json['nprop'] as String? ?? '',
      nkab: json['nkab'] as String? ?? '',
      kejadian: json['kejadian'] as String? ?? '',
      tanggal: json['tanggal'] as String? ?? '',
      longitude: json['longitude'] as String? ?? '',
      latitude: json['latitude'] as String? ?? '',
      keterangan: json['keterangan'] as String? ?? '',
      penyebab: json['penyebab'] as String? ?? '',
      kronologis: json['kronologis'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'nprop': nprop,
        'nkab': nkab,
        'kejadian': kejadian,
        'tanggal': tanggal,
        'longitude': longitude,
        'latitude': latitude,
        'keterangan': keterangan,
        'penyebab': penyebab,
        'kronologis': kronologis,
      };
}
