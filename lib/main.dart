  import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AudioPlayer audioPlayer = AudioPlayer();

  Future<void> playSound(String name) async {
    try {
      await audioPlayer.play(AssetSource('sounds/$name.mp3'));
    } catch (_) {}
  }

  final List<String> vowels = ['а', 'о', 'у', 'э', 'и', 'ы', 'я', 'ё', 'ю', 'е'];
  final List<String> consonants = [
    'б', 'в', 'г', 'д', 'ж', 'з', 'й', 'к', 'л', 'м', 'н', 'п', 'р', 'с', 'т', 'ф', 'х', 'ц', 'ч', 'ш', 'щ'
  ];

  bool isVowel(String ch) => vowels.contains(ch);

  bool isValidVC(String v, String c) {
    if (v == 'ы' && ['щ', 'ф', 'ц', 'ч', 'ш', 'ж'].contains(c)) return false;
    return true;
  }

  bool isValidCV(String c, String v) {
    if (v == 'ы' && ['й', 'ч', 'щ', 'ж', 'ш', 'ц'].contains(c)) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Слоги и буквы'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Гласн.+Согласн.'),
                Tab(text: 'Согласн.+Гласн.'),
                Tab(text: 'Слоги 1'),
                Tab(text: 'Слоги 2'),
              ],
            ),
          ),
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // 1 — гласная + согласная
              buildScrollTable(
                rowHeaders: vowels,
                colHeaders: consonants,
                isValid: isValidVC,
                rowHeaderIsVowel: true,
                colHeaderIsVowel: false,
                compose: (r, c) => '$r$c',
              ),
              // 2 — согласная + гласная
              buildScrollTable(
                rowHeaders: consonants,
                colHeaders: vowels,
                isValid: isValidCV,
                rowHeaderIsVowel: false,
                colHeaderIsVowel: true,
                compose: (r, c) => '$r$c',
              ),
              // 3
              buildSyllableGrid(playSound, [
                'мак','кот','дом','рис','лук','лес','сад','нос','бар','пол',
                'ток','сон','мир','бак','зуб','пух','луг','рот','рак','жар',
                'дым','кит','шум','сок','век','хут','шар','сыр','вор','мух',
                'пир','губ','жук','мех','шик','чик','щип','шип','жир','кам',
                'рам','лам','пад','шам','сам','нам','там','хам','фак'
              ]),
              // 4
              buildSyllableGrid(playSound, [
                'бри','ври','гли','дря','кри','пли','сли','тря','фли','шли',
                'бра','про','тра','дро','кро','гру','пла','мра','шра','фло',
                'жра','бра','тро','кла','вру','бле','вра','гле','дрё','клу',
                'плё','мро','шла','фро','брю','трю','кла','врю','зла','сло'
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildScrollTable({
    required List<String> rowHeaders,
    required List<String> colHeaders,
    required bool Function(String, String) isValid,
    required bool rowHeaderIsVowel,
    required bool colHeaderIsVowel,
    required String Function(String, String) compose,
  }) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Row(
                  children: [
                    _headerCell(''),
                    ...colHeaders.map(
                      (c) => _letterCell(
                        c,
                        isVowel: colHeaderIsVowel,
                        onTap: () => playSound(c),
                        header: true,
                      ),
                    ),
                  ],
                ),
                ...rowHeaders.map((r) {
                  return Row(
                    children: [
                      _letterCell(
                        r,
                        isVowel: rowHeaderIsVowel,
                        onTap: () => playSound(r),
                        header: true,
                      ),
                      ...colHeaders.map((c) {
                        if (!isValid(r, c)) {
                          return _emptyCell();
                        }
                        final syll = compose(r, c);
                        return _coloredSyllableCell(
                          syll,
                          onTap: () => playSound(syll),
                        );
                      }),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerCell(String text) {
    return Container(
      alignment: Alignment.center,
      width: 50,
      height: 50,
      color: Colors.grey[200],
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _letterCell(String letter,
      {required bool isVowel, required VoidCallback onTap, bool header = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: 50,
        height: 50,
        color: header ? Colors.grey[200] : Colors.white,
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isVowel ? Colors.red : Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _coloredSyllableCell(String syllable, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: 50,
        height: 50,
        color: Colors.white,
        child: Text.rich(
          TextSpan(
            children: syllable.split('').map((ch) {
              return TextSpan(
                text: ch,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isVowel(ch) ? Colors.red : Colors.blue,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _emptyCell() {
    return Container(
      alignment: Alignment.center,
      width: 50,
      height: 50,
      color: Colors.white,
    );
  }

  Widget buildSyllableGrid(Function(String) playSound, List<String> syllables) {
    return GridView.count(
      crossAxisCount: 5,
      children: syllables.map((syllable) {
        return GestureDetector(
          onTap: () => playSound(syllable),
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(4),
            color: Colors.grey[100],
            child: Text(
              syllable,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        );
      }).toList(),
    );
  }
}

    
                