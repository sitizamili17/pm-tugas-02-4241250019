import 'dart:io';

/// Satu produk di katalog: nama, kategori, harga (Record).
typedef Produk = ({String nama, String kategori, int harga});

/// Mengubah 45000 menjadi "45.000".
String rupiah(int n) =>
    n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');

void main() {
  // Map: kode -> Record produk
  final Map<String, Produk> katalog = {
    'P01': (nama: 'Kopi Sidikalang 250 g', kategori: 'Kopi', harga: 45000),
    'P02': (nama: 'Kopi Gayo 250 g', kategori: 'Kopi', harga: 55000),
    'P03': (nama: 'Teh Kayu Aro 100 g', kategori: 'Teh', harga: 25000),
    'P04': (nama: 'Gula Aren 500 g', kategori: 'Pemanis', harga: 30000),
    'P05': (nama: 'Bolu Meranti', kategori: 'Makanan', harga: 80000),
  };

  // TODO 1: katalog sebagai tabel rapi
  print('KATALOG TOKO OLEH-OLEH MEDAN');
  print('=' * 44);
  print('${'Kode'.padRight(6)}${'Nama'.padRight(26)}${'Harga'.padLeft(12)}');
  print('-' * 44);
  for (final e in katalog.entries) {
    print(
      '${e.key.padRight(6)}'
      '${e.value.nama.padRight(26)}'
      '${rupiah(e.value.harga).padLeft(12)}',
    );
  }
  print('=' * 44);

  stdout.write('Pesanan (contoh: P01x2, P03x1): ');
  final String input = stdin.readLineSync() ?? '';

  // TODO 2 + 3: urai input, tangani kode salah tanpa crash
  final List<({Produk produk, int jumlah})> pesanan = [];
  final List<String> ditolak = [];

  for (final bagian in input.split(',')) {
    final item = bagian.trim();
    if (item.isEmpty) continue;

    final pecah = item.toLowerCase().split('x');
    if (pecah.length != 2) {
      ditolak.add('$item (format harus KODExJUMLAH)');
      continue;
    }

    final kode = pecah[0].trim().toUpperCase();
    final jumlah = int.tryParse(pecah[1].trim()); // int? (bisa null)
    final produk = katalog[kode]; // Produk? (null bila kode tidak ada)

    if (produk == null) {
      ditolak.add('$item (kode tidak ada)');
    } else if (jumlah == null || jumlah <= 0) {
      ditolak.add('$item (jumlah tidak valid)');
    } else {
      // Di sini produk dan jumlah sudah pasti tidak null,
      // jadi tidak perlu tanda seru (!).
      pesanan.add((produk: produk, jumlah: jumlah));
    }
  }

  if (pesanan.isEmpty) {
    print('\nTidak ada pesanan yang valid.');
    if (ditolak.isNotEmpty) print('Ditolak: ${ditolak.join(', ')}');
    return;
  }

  // TODO 4: subtotal dengan map, total dengan fold, diskon
  final baris = pesanan
      .map(
        (p) => (
          nama: p.produk.nama,
          kategori: p.produk.kategori,
          jumlah: p.jumlah,
          subtotal: p.produk.harga * p.jumlah,
        ),
      )
      .toList();

  final int total = baris.fold<int>(0, (sum, b) => sum + b.subtotal);
  final int diskon = total >= 100000 ? total ~/ 10 : 0;
  final int bayar = total - diskon;
  final Set<String> kategori = baris.map((b) => b.kategori).toSet();

  // TODO 5: cetak struk
  print('\n${'STRUK BELANJA'.padLeft(28)}');
  print('-' * 44);
  for (final b in baris) {
    print(
      '${b.nama.padRight(24)}'
      '${'${b.jumlah} x'.padLeft(5)}'
      '${rupiah(b.subtotal).padLeft(15)}',
    );
  }
  print('-' * 44);
  print('${'Total'.padRight(29)}${rupiah(total).padLeft(15)}');
  print('${'Diskon 10%'.padRight(29)}${rupiah(diskon).padLeft(15)}');
  print('${'Bayar'.padRight(29)}${rupiah(bayar).padLeft(15)}');
  print('-' * 44);
  print('Kategori dibeli : ${kategori.join(', ')}');
  if (ditolak.isNotEmpty) {
    print('Item ditolak    : ${ditolak.join('; ')}');
  }
}
