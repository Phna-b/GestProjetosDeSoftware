Sistema de Gestão para a Semana da Computação do DECSI
Este é um projeto universitário desenvolvido para a disciplina de Gerência de Projetos de Software (CSI405) da Universidade Federal de Ouro Preto (UFOP). O sistema foi construído para dar suporte à Semana da Computação do Departamento de Computação e Sistemas (DECSI), com o objetivo de centralizar informações e melhorar a experiência dos participantes.

A aplicação consiste num backend desenvolvido em Python com Flask e um frontend em Flutter, que se comunicam para fornecer as funcionalidades.

Funcionalidades Principais
Autenticação de Utilizadores: Sistema de registo e login para os participantes atrvés de contas google.

Calendário de Eventos: Visualização da programação completa do evento, com a capacidade de filtrar eventos favoritos.

Detalhes do Evento: Visualização de informações detalhadas sobre cada palestra ou atividade.

Agenda Personalizada: Funcionalidade que permite aos utilizadores inscreverem-se nos eventos de seu interesse.

Envio de Perguntas: Sistema para que os participantes possam enviar perguntas durante as palestras.

Check-in nos eventos: Sistema que gerencia quem pode realizar perguntas em um evento.

Tecnologias Utilizadas
O projeto foi dividido em duas partes principais: o backend e o frontend.

Backend 

Firebase para gerenciamento dos endpoints e base de dados.

Frontend 
Framework: Flutter

Linguagem: Dart

Dependências Principais (pubspec.yaml):

Como Executar o Projeto

Executar o Frontend (Aplicação Flutter)

# 1. Navegue para a pasta do frontend
cd "Flutter project/arg_clean"

# 2. Descarregue as dependências do Flutter (apenas na primeira vez)
flutter pub get

# 3. Execute a aplicação (escolha uma das opções abaixo)

### Para executar no navegador Chrome
flutter run -d chrome

### Para executar no Android 

Acesse no modo depuração e execute:
adb install -r build\app\outputs\flutter-apk\app-debug.apk
