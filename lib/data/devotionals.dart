import '../models.dart';

/// Conteúdo PROVISÓRIO de devocionais.
/// TODO: substituir pelos devocionais reais (a partir do PDF enviado).
/// A função [devotionalForDate] seleciona um devocional por dia.
const List<Devotional> _devotionals = [
  Devotional(
    id: 1,
    verseRef: 'Salmos 46:1',
    verse: 'Deus é o nosso refúgio e fortaleza, socorro bem presente na angústia.',
    title: 'Um refúgio para hoje',
    body:
        'Em meio à correria e aos desafios, Deus se apresenta como um refúgio seguro. '
        'Não precisamos carregar o peso sozinhos: podemos descansar na presença dEle. '
        'Hoje, entregue a Ele aquilo que tem tirado a sua paz e confie no cuidado do Pai.',
  ),
  Devotional(
    id: 2,
    verseRef: 'Provérbios 3:5-6',
    verse:
        'Confia no Senhor de todo o teu coração e não te estribes no teu próprio entendimento.',
    title: 'Confiar sem ver tudo',
    body:
        'Muitas vezes queremos entender tudo antes de dar o próximo passo. '
        'Mas a fé nos convida a confiar mesmo quando o caminho não está claro. '
        'Deus enxerga o que ainda não enxergamos e dirige os nossos passos com sabedoria.',
  ),
  Devotional(
    id: 3,
    verseRef: 'Hebreus 6:19',
    verse:
        'Temos esta esperança como âncora da alma, firme e segura.',
    title: 'Âncora para a alma',
    body:
        'As ondas da vida vêm e vão, mas a esperança em Deus é uma âncora que não se move. '
        'Mesmo quando tudo parece instável, há algo firme para segurar. '
        'Agarre-se a essa âncora e deixe que ela mantenha o seu coração em paz.',
  ),
  Devotional(
    id: 4,
    verseRef: '2 Coríntios 5:7',
    verse: 'Porque andamos por fé, e não por vista.',
    title: 'Andar por fé',
    body:
        'Andar por vista é reagir apenas ao que se vê; andar por fé é responder àquilo que Deus prometeu. '
        'A fé transforma a forma como encaramos as dificuldades. '
        'Que hoje os seus passos sejam guiados pela confiança em Deus, e não pelo medo.',
  ),
  Devotional(
    id: 5,
    verseRef: 'Filipenses 4:6-7',
    verse:
        'Não andeis ansiosos por coisa alguma; antes, as vossas petições sejam conhecidas diante de Deus pela oração.',
    title: 'Paz no lugar da ansiedade',
    body:
        'A ansiedade tenta ocupar o nosso coração, mas a oração abre espaço para a paz. '
        'Leve a Deus cada preocupação, por menor que pareça. '
        'Ele promete uma paz que excede todo entendimento, guardando o seu coração e a sua mente.',
  ),
  Devotional(
    id: 6,
    verseRef: 'Lamentações 3:22-23',
    verse:
        'As misericórdias do Senhor são a causa de não sermos consumidos, porque as suas misericórdias não têm fim; renovam-se cada manhã.',
    title: 'Novas cada manhã',
    body:
        'Cada novo dia é uma prova do amor renovado de Deus. '
        'O que passou não define o que está por vir. '
        'Receba este dia como um presente e recomece com esperança.',
  ),
  Devotional(
    id: 7,
    verseRef: 'Filipenses 4:13',
    verse: 'Posso todas as coisas naquele que me fortalece.',
    title: 'Força que vem de Deus',
    body:
        'Não é pela nossa própria força que vencemos, mas pela força que Deus nos dá. '
        'Quando a energia acaba, Ele renova. '
        'Enfrente o dia com a certeza de que você não está sozinho.',
  ),
];

/// Retorna o devocional do dia, baseado no dia do ano.
Devotional devotionalForDate(DateTime date) {
  final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
  return _devotionals[dayOfYear % _devotionals.length];
}

/// Quantidade de devocionais disponíveis (útil para testes).
int get devotionalCount => _devotionals.length;
