# ⚽ FutDle - O "Wordle" do Futebol

Um jogo de adivinhação diária de jogadores de futebol inspirado no Wordle. O jogador precisa descobrir qual é o "Jogador Misterioso do Dia" baseado em dicas de atributos (Nacionalidade, Liga, Time, Posição e Idade).

## 👨‍💻 Autor
**Vitor Hugo Fernandes Costa** - Estudante de Engenharia de Software  
GitHub: [@VitorFcosta](https://github.com/VitorFcosta) | [LinkedIn](https://www.linkedin.com/in/vitor-hugo-fernandes-costa-122419300/)

---

## 🎯 Sobre o Projeto (Trabalho do 1º Bimestre)

Este projeto foi desenvolvido como requisito de avaliação da disciplina, cumprindo 100% das exigências propostas:
- ✅ **[2 pontos]** Aplicação exibindo dados de API (API-Football)
- ✅ **[2 pontos]** Integração com Firebase (Authentication e Cloud Firestore)
- ✅ **[2 pontos]** README bem feito com orientação de utilização e tecnologias
- ✅ **[1 ponto]** Código-fonte Dart corretamente versionado
- ✅ **[1 ponto]** Desenho da arquitetura da aplicação
- ✅ **[1 ponto]** Prints da aplicação
- ✅ **[1 ponto]** Link para baixar o apk / versão web

---

## 🏗️ Arquitetura da Aplicação

Para otimizar o consumo da API externa e garantir a escalabilidade do jogo, a aplicação foi arquitetada para que o App Flutter se comunique apenas com o Firebase. O Firebase, por sua vez, é alimentado diariamente com os dados da API de esportes.

![Desenho da Arquitetura do FutDle](https://github.com/VitorFcosta/futdle/blob/main/Imagens/FootEDL.drawio.png)

---

## 📂 Estrutura do Projeto

O projeto segue uma arquitetura baseada em *Features* para garantir escalabilidade e separação de responsabilidades:

```text
lib/
├── core/                     # Núcleo da aplicação 
│   ├── api/                  # Serviços e constantes da API externa
│   ├── di/                   # Configuração de injeção de dependências
│   ├── exceptions/           # Tratamento de erros customizados
│   ├── firebase/             # Serviços do Firebase 
│   ├── logger/               # Sistema centralizado de logs
│   ├── managers/             # Gerenciadores lógicos 
│   ├── models/               # Modelos de dados globais
│   ├── theme/                # Sistema de design 
│   └── utils/                # Funções utilitárias e mappers
├── features/                 # Módulos funcionais do app
│   ├── admin/                # Tela e controle do painel de administração
│   ├── auth/                 # Fluxo de login, registro e controle de acesso 
│   ├── home/                 # Tela inicial e seleção de jogos
│   └── wordle/               # Lógica, interface e estatísticas do jogo principal
├── firebase_options.dart     # Configurações geradas pelo FlutterFire
└── main.dart                 # Ponto de entrada e inicialização do app
```
🚀 Tecnologias e Pacotes Utilizados
Flutter & Dart: Framework e linguagem base.

Firebase Auth & Cloud Firestore: Gerenciamento de usuários, banco de dados NoSQL e controle de acesso integrado ao AuthGate.

API-Football (via RapidAPI): Fonte dos dados reais dos jogadores.

GetIt: Padrão de Injeção de Dependências (DI) para desacoplar os serviços.

Flutter DotEnv: Gerenciamento seguro de chaves de API via variáveis de ambiente.

Cached Network Image: Otimização e cache no carregamento de imagens.

Country Flags: Exibição de bandeiras com base na nacionalidade dos jogadores.

Google Fonts: Fontes Outfit e JetBrains Mono.

⚙️ Como Instalar e Rodar o Projeto
Siga os passos abaixo para testar a aplicação na sua máquina:

1. Pré-requisitos:

Ter o Flutter SDK instalado (SDK ^3.11.1)
Ter um emulador configurado ou dispositivo conectado

2. Clonando o repositório:

```
git clone [https://github.com/VitorFcosta/futdle.git](https://github.com/VitorFcosta/futdle.git)
cd futdle
```
3. Configure as variáveis de ambiente (.env):

Na raiz do projeto, você verá um arquivo chamado .env.example
Crie um arquivo novo chamado .env no mesmo local
Copie o conteúdo de .env.example para dentro do .env e substitua a chave pela sua chave real da API-Sports

4. Instalando dependências:
````
flutter pub get
````
5. Rodando o aplicativo:

```
flutter run
```
## 📱 Prints da Aplicação

<p align="center">
  <img src="Imagens/flutter_01.png" width="200" alt="Tela Inicial">
  &nbsp;&nbsp;&nbsp;
  <img src="Imagens/Pagina_jogo.png" width="200" alt="Gameplay">
  &nbsp;&nbsp;&nbsp;
  <img src="Imagens/popup.png" width="200" alt="Popup de Resultado">
  &nbsp;&nbsp;&nbsp;
  <img src="Imagens/Historico.png" width="200" alt="Histórico de Jogos">
</p>
