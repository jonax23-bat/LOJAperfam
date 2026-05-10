# Perfumes da Mayara - Catálogo Inteligente 🌸✨

Sistema de catálogo digital de perfumes com inteligência artificial para identificação automática de produtos e gestão de estoque.

## 🚀 Funcionalidades Principais

### 1. Inteligência Artificial (Gemini 1.5 Flash)
- **Análise de Imagem**: O revendedor tira uma foto do perfume e o sistema identifica automaticamente o nome, a marca e a família olfativa.
- **Integração Manual**: Utilizamos chamadas diretas via HTTP à API do Google (v1beta) para garantir máxima estabilidade e contornar bugs de SDK.

### 2. Visão do Cliente (Catálogo)
- **Navegação Fluida**: Catálogo responsivo com grid de produtos.
- **Detalhes do Produto**: Página dedicada com informações técnicas e foto ampliada.
- **Reserva via WhatsApp**: Integração direta para fechar pedidos com mensagem pré-configurada.

### 3. Área do Revendedor (Gestão)
- **Portaria de Acesso**: Separação clara entre a interface pública e a de gestão.
- **Cadastro Inteligente**: Formulário de "Novo Produto" otimizado com a câmera e IA.

---

## 🛠️ Tecnologias Utilizadas
- **Framework**: Flutter (Web & Mobile)
- **Estado**: Riverpod
- **IA**: Google Gemini 1.5 Flash (via Manual HTTP)
- **Estilização**: AppTheme Customizado (Cores: Vinho e Dourado)

---

## 🏃 Como Rodar o Projeto

1. Certifique-se de ter o Flutter instalado.
2. Clone o repositório.
3. Execute `flutter pub get`.
4. Para rodar a versão Web acessível no celular (Wi-Fi):
   ```bash
   flutter run -d web-server --web-port 5000 --web-hostname 0.0.0.0
   ```
5. Acesse no celular via: `http://SEU-IP:5000`

---

## 🛡️ Notas de Desenvolvimento
- **Bug Fix**: Corrigido erro de "Image.file" na Web usando `Image.memory` com bytes.
- **Estabilidade**: Implementada limpeza de cache e reinicialização forçada de porta para evitar conflitos de soquete (Erro 10048).

---
*Documentação gerada automaticamente pela Antigravity AI em 10 de Maio de 2024.*
