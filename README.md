⚽ FutDle - O "Wordle" do Futebol

Um jogo de adivinhação diária de jogadores de futebol inspirado no Wordle. O jogador precisa descobrir qual é o "Jogador Misterioso do Dia" baseado em dicas de atributos (Nacionalidade, Liga, Time, Posição e Idade).

## 👨‍💻 Autor
**Vitor Hugo Fernandes Costa** Estudante de Engenharia de Software  
GitHub: [@VitorFcosta](https://github.com/VitorFcosta) | [LinkedIn](URL_DO_SEU_LINKEDIN_AQUI)

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
![Desenho da Arquitetura do FutDle](https://github.com/VitorFcosta/futdle/blob/main/FootEDL.drawio.png)

---

## 🚀 Tecnologias Utilizadas

* **[Flutter](https://flutter.dev/):** Framework principal para desenvolvimento da interface mobile/web.
* **[Dart](https://dart.dev/):** Linguagem de programação base.
* **[Firebase Authentication](https://firebase.google.com/):** Gerenciamento de login e criação de usuários.
* **[Cloud Firestore (Firebase)](https://firebase.google.com/):** Banco de dados NoSQL para armazenar o jogador do dia e as estatísticas dos usuários.
* **[API-Football (via RapidAPI)](https://www.api-football.com/):** API externa utilizada para obter os dados reais dos jogadores de futebol.

---

## ⚙️ Como Instalar e Rodar o Projeto

Siga os passos abaixo para clonar e testar a aplicação na sua máquina:

**1. Pré-requisitos:**
* Ter o [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado.
* Ter um emulador configurado (Android/iOS) ou um dispositivo físico conectado.

**2. Clonando o repositório:**
```bash
git clone https://github.com/VitorFcosta/futdle.git
cd futdle
```

**3. Crie a chave da API**
- Este projeto consome dados da [API-Sports (Football)](https://www.api-football.com/).
- Crie uma conta lá para pegar sua `API_KEY`.

**4. Configure as variáveis de ambiente**
- Na raiz do projeto, você verá um arquivo chamado `.env.example`.
- Crie um arquivo novo chamado `.env` no mesmo local.
- Copie o conteúdo do `.env.example` para dentro do seu novo `.env` e substitua `sua_chave_da_api_sports_aqui` pela chave real que você pegou no site.

**5. Instalando dependências e Rodando:**
```bash
flutter pub get
flutter run
```

---

## 📱 Prints da Aplicação
- Telas prototipo
- Tela de Login
- Tela Inicial
- Tela de Jogo (Gameplay)

## 📥 Download e Teste
- Baixar APK (Android): Clique aqui para baixar a versão mais recente
- Testar Versão Web: Acessar FutDle Web
