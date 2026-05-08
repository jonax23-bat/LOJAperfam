# Plano de Desenvolvimento: App "Perfumes da Mayara"

## 1. Visão Geral do Projeto
O aplicativo funcionará como um **catálogo digital premium** para revendedores de perfumes (foco inicial: Pronta-Entrega). Ele fornecerá uma interface "estilo revista" para clientes e um sistema de gestão simplificado e automatizado via Inteligência Artificial para o revendedor.

- **Nome da Loja:** Perfumes da Mayara
- **Identidade Visual:** Minimalista e elegante (Premium).
- **Cores Principais:** Vinho (Fundos principais/Cabeçalhos), Verde Escuro (Botões de ação/WhatsApp) e Dourado (Selo Pronta Entrega/Detalhes).

---

## 2. Arquitetura e Stack Tecnológico
- **Front-end (Mobile):** Flutter (Compatível com Android e iOS).
  - Padrão de Arquitetura: Clean Architecture ou MVVM.
  - Gerenciamento de Estado: Riverpod ou BLoC.
- **Back-end & Banco de Dados:** Firebase.
  - Banco de Dados: Firestore (NoSQL, Tempo real).
  - Arquivos: Firebase Storage (para imagens de produtos).
- **Inteligência Artificial:** Google Gemini API (Visão Computacional e Geração de Texto).

---

## 3. Arquitetura Multi-Tenant (Múltiplas Revendedoras)

Para garantir que cada revendedora tenha o seu próprio "banco de dados" isolado e seus próprios clientes, utilizaremos o padrão **Multi-tenant** via subcoleções no Firestore:

- **Estrutura de Dados:**
  - `Revendedoras` (Coleção) -> `{ID_da_Revendedora}` (Documento) -> `Produtos` (Subcoleção exclusiva)
  - `Revendedoras` (Coleção) -> `{ID_da_Revendedora}` (Documento) -> `Clientes` (Subcoleção exclusiva)
- **Conexão Cliente-Revendedora:**
  - A revendedora compartilhará um **Deep Link único** (ex: `app.com/mayara`).
  - Ao clicar, o aplicativo abre e vincula aquele celular permanentemente ao ID da revendedora.
  - O cliente fará o cadastro simplificado (Nome e WhatsApp) no momento da primeira reserva. O cliente não precisa criar senhas complexas.
- **Segurança:** As *Firebase Security Rules* garantirão que os dados de uma revendedora sejam inacessíveis para outras.

---

## 4. Divisão da Equipe (3 Programadores)

### 🧑‍💻 Programador 1: Back-end, Infra e IA
**Foco principal:** Motor do aplicativo e banco de dados.
- Configurar o projeto no Firebase (Firestore e Storage).
- Desenvolver microserviço/Cloud Function para integrar com a API do Gemini (receber imagem -> retornar "Nome" e "Notas Olfativas").
- Criar regras de concorrência no banco de dados (ex: travar o estoque automaticamente quando um item de unidade única for reservado).

### 🧑‍💻 Programador 2: Front-end (Jornada do Revendedor / Admin)
**Foco principal:** Fluxo de cadastro de produtos.
- Configurar o projeto inicial em Flutter (Rotas, Cores Globais, Temas).
- Desenvolver tela de Dashboard do Revendedor (Feed de produtos).
- Implementar integração nativa da câmera (`image_picker`) para capturar fotos com tratamento para permissões negadas.
- Criar formulário de cadastro que preenche os campos com a resposta da IA e permite ajuste manual de preço e quantidade.

### 🧑‍💻 Programador 3: Front-end (Jornada do Cliente / Catálogo)
**Foco principal:** Experiência visual do usuário e conversão.
- Desenvolver a "Revista Virtual", vitrine com foco em imagens limpas.
- Implementar tela de Detalhes do Produto.
- Criar a lógica de integração com o WhatsApp (geração de mensagens automáticas via `url_launcher` informando o produto reservado).
- Integrar Deep Links para permitir o compartilhamento direto de produtos específicos no Instagram/WhatsApp.

---

## 5. Requisitos e Validações Técnicas (Mobile)

Para garantir uma aplicação profissional, fluida e com padrão de mercado, a equipe de front-end deverá seguir estas diretrizes rigorosas:

1. **Otimização de Imagens (Crucial):**
   - Utilizar o pacote `cached_network_image` no Flutter para evitar re-download de fotos a cada visita, economizando plano de dados e acelerando o tempo de carregamento.
   - Usar *Shimmer Effects* (esqueletos de carregamento) estilizados nas transições para omitir carregamentos da rede.

2. **UX Premium e Animações:**
   - O catálogo exige um design refinado. Implementar **Hero Animations** no Flutter nas fotos dos perfumes, fazendo com que a imagem do catálogo deslize e expanda suavemente ao abrir a tela de detalhes.

3. **Funcionamento Offline:**
   - O Firebase possui suporte nativo a cache. O Front-end deve configurar o aplicativo para funcionar mesmo sem internet na visualização do catálogo e alertar o usuário através da UI quando ele estiver sem rede durante o uso de funções dependentes da nuvem (como enviar foto para a IA).

4. **Tratamento Seguro de Estado:**
   - Como o controle de estoque de Pronta Entrega é em tempo real, qualquer alteração feita no backend por um cliente (reserva) deve refletir instantaneamente no front-end de outros clientes usando `Streams` do Firestore.

---

## 6. Cronograma Macro

- **Semana 1:** Setup de Banco de Dados (Prog 1) e Criação/Configuração inicial do repositório Flutter (Prog 2 e 3).
- **Semana 2:** Integração de API do Gemini para texto/imagem (Prog 1), Criação do fluxo de upload (Prog 2) e Consumo dos dados simulados na UI principal (Prog 3).
- **Semana 3:** Conexão total das pontas. Testes de sincronização de estoque, animações, polimento visual e botão WhatsApp.
