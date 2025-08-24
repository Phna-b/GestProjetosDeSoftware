import 'package:intl/intl.dart';
import '../models/event.dart';

// Lista hardcoded de eventos (IDs fixos!)
final List<Event> kStaticEvents = [
  // --- 07 de julho (segunda-feira) ---
  Event(
    id: 'evt-2025-07-07-maratona',
    title: 'Maratona de Programação',
    date: DateTime(2025, 7, 7, 13, 30),
    endDate: DateTime(2025, 7, 7, 17, 20),
    location: 'Lab. C207',
    description: 'Professor Eduardo Ribeiro (DECSI - UFOP JM). Treinamento prévio: 30/06, 18h00-18h50 no Lab. C207.',
  ),
  Event(
    id: 'evt-2025-07-07-fedllm',
    title: 'Minicurso: Introdução ao Aprendizado Federado Aplicado a LLMs (FedLLM)',
    date: DateTime(2025, 7, 7, 13, 30),
    endDate: DateTime(2025, 7, 7, 15, 20),
    location: 'Lab. C204',
    description: 'Professor Roberto Ribeiro (DECSI - UFOP JM).',
  ),
  Event(
    id: 'evt-2025-07-07-ml',
    title: 'Minicurso: Introdução ao Machine Learning',
    date: DateTime(2025, 7, 7, 15, 30),
    endDate: DateTime(2025, 7, 7, 17, 20),
    location: 'Lab. H102',
    description: 'Professor Alexandre Magno (DECSI - UFOP JM). Recomendado levar notebook.',
  ),
  Event(
    id: 'evt-2025-07-07-ia-etica',
    title: 'Abertura + Mesa Redonda: IA e Ética',
    date: DateTime(2025, 7, 7, 18, 50),
    endDate: DateTime(2025, 7, 7, 20, 50),
    location: 'Auditório (Presencial)',
    description: 'Com Danilo Almeida (Google), Eduardo Ribeiro (DECSI - UFOP JM), Elton Máximo (DECSI - UFOP JM), Vicente Amorim (Dell) e Wagner Ragi (DEENP - UFOP JM).',
  ),
  Event(
    id: 'evt-2025-07-07-google',
    title: 'Palestra: Da Universidade para o Google',
    date: DateTime(2025, 7, 7, 21, 0),
    endDate: DateTime(2025, 7, 7, 22, 0),
    location: 'Auditório (Presencial)',
    description: 'Palestrante: Danilo Almeida (Google).',
  ),

  // --- 08 de julho (terça-feira) ---
  Event(
    id: 'evt-2025-07-08-midias',
    title: 'Minicurso: Coleta de Dados em Mídias Sociais Online',
    date: DateTime(2025, 7, 8, 13, 30),
    endDate: DateTime(2025, 7, 8, 17, 20),
    location: 'Lab. H102',
    description: 'Filipe Moura (Mestrando UFMG).',
  ),
  Event(
    id: 'evt-2025-07-08-arvr',
    title: 'Minicurso: Realidade Aumentada e Virtual',
    date: DateTime(2025, 7, 8, 13, 30),
    endDate: DateTime(2025, 7, 8, 17, 20),
    location: 'Lab. C207',
    description: 'Professor Maurício Aureliano (DECSI - UFOP JM).',
  ),
  Event(
    id: 'evt-2025-07-08-saude-mental',
    title: 'Palestra: Cuidado com a Saúde Mental',
    date: DateTime(2025, 7, 8, 18, 50),
    endDate: DateTime(2025, 7, 8, 20, 0),
    location: 'Auditório (Presencial)',
    description: 'Renata Viana (Psicóloga e professora DOCTUM JM).',
  ),
  Event(
    id: 'evt-2025-07-08-mineracao',
    title: 'Palestra: Aplicações de Mineração de Dados em Redes Sociais',
    date: DateTime(2025, 7, 8, 20, 0),
    endDate: DateTime(2025, 7, 8, 21, 0),
    location: 'Auditório (Presencial)',
    description: 'Professora Hellen Lima (DECSI - UFOP JM).',
  ),

  // --- 09 de julho (quarta-feira) ---
  Event(
    id: 'evt-2025-07-09-debian',
    title: 'Minicurso: Festival de Instalação de Debian GNU/Linux',
    date: DateTime(2025, 7, 9, 13, 30),
    endDate: DateTime(2025, 7, 9, 17, 20),
    location: 'Lab. H102',
    description: 'Professor Igor Muzetti (DECSI - UFOP JM).',
  ),
  Event(
    id: 'evt-2025-07-09-vr-industria',
    title: 'Palestra: Realidade Virtual e Indústria',
    date: DateTime(2025, 7, 9, 18, 50),
    endDate: DateTime(2025, 7, 9, 20, 0),
    location: 'Auditório (Presencial)',
    description: 'Professor Maurício Aureliano (DECSI - UFOP JM).',
  ),
  Event(
    id: 'evt-2025-07-09-encerramento',
    title: 'Encerramento / Mesa Redonda: Mercado e Academia',
    date: DateTime(2025, 7, 9, 20, 0),
    endDate: DateTime(2025, 7, 9, 21, 0),
    location: 'Auditório (Remoto/Presencial)',
    description: 'Discussão sobre interseção entre mercado e academia.',
  ),
];

String formatDay(DateTime dt) => DateFormat('dd/MM/yyyy – HH:mm').format(dt);