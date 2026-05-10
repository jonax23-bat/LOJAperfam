# PROXIMOS PASSOS: Zetta Vitrine 🚀

O sistema foi transformado com sucesso em uma plataforma SaaS (Software as a Service) com estrutura completa de assinaturas, controle de revendedoras, administração global e roteamento de pedidos de WhatsApp. 

Para que a plataforma seja lançada OFICIALMENTE ao mercado e comece a faturar, estas são as pendências e os próximos passos que precisamos executar:

## 1. Contas de Pagamento Reais (Obrigatório)
O sistema de "Checkout" atual está simulando os pagamentos para testes. Para processarmos dinheiro real:
- [ ] **Criar Conta no Mercado Pago**: Criar a conta com o seu CPF/CNPJ para gerar as chaves "Public Key" e "Access Token".
- [ ] **Criar Conta na Google Play Console**: Pagar a taxa de \$25 do Google para podermos publicar o aplicativo na Play Store e configurar o "Google Play Billing" (via plataforma RevenueCat) para assinaturas no celular.

## 2. Webhooks e Segurança no Servidor (Firebase)
- [ ] **Programar os Webhooks**: Quando o Mercado Pago confirmar que a revendedora pagou um PIX, ele vai bater no nosso Firebase. Precisamos escrever as "Firebase Cloud Functions" (funções de nuvem) que vão pegar essa notificação e alterar o plano dela de `teste` para `mensal` automaticamente.
- [ ] **Regras de Segurança (Firestore Rules)**: Bloquear o banco de dados para garantir que apenas o Administrador (`admin@zettahub.com.br`) consiga mudar planos e que nenhuma revendedora acesse os dados das outras.

## 3. Domínio e Hospedagem na Web
- [ ] **Comprar o Domínio Oficial**: Comprar `zettavitrine.com.br` (ou similar) no Registro.br.
- [ ] **Publicar no Firebase Hosting**: Tirar o aplicativo do `localhost:5000` (seu computador) e publicá-lo de verdade na nuvem para que clientes do Brasil todo possam acessar.

## 4. Refinamentos Finais do Catálogo
- [ ] Ativar as imagens reais e os filtros categorizados do catálogo de clientes.
- [ ] Configurar a proteção para ocultar o catálogo se o plano da revendedora estiver constando como `inativo`.

---
*Assim que você tiver as contas do Mercado Pago e do Google criadas, podemos executar essas pendências e fazer o grande lançamento!* 💎
