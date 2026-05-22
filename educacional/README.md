# StudyFlex+

**StudyFlex+** é uma plataforma de streaming acadêmico desenvolvida com Flutter, que oferece vídeos educacionais organizados por categorias, com sistema de autenticação, favoritos, histórico de visualização e perfil personalizado.

![Flutter](https://img.shields.io/badge/Flutter-3.16+-02569B?style=flat&logo=flutter)
![Supabase](https://img.shields.io/badge/Supabase-3.0+-3FCF8E?style=flat&logo=supabase)
![Dart](https://img.shields.io/badge/Dart-3.2+-0175C2?style=flat&logo=dart)

## Funcionalidades

- **Autenticação completa** – Login e cadastro de usuários com Supabase Auth
- **Catálogo de vídeos** – Listagem com seções: "Mais Assistidos", "Recentes" e "Recomendados"
- **Player integrado** – Reprodução de vídeos do YouTube com YouTube Player Iframe
- **Sistema de favoritos** – Salve vídeos para assistir depois
- **Histórico automático** – Registro de todos os vídeos assistidos
- **Perfil do usuário** – Edite foto, nome, curso e bio. Veja estatísticas de uso
- **Navegação fluida** – Bottom navigation bar com 4 seções principais
- **Design moderno** – Tema escuro com paleta verde (#10B981) e animações

## Tecnologias

| Tecnologia | Versão | Finalidade |
|------------|--------|------------|
| Flutter | 3.16+ | Framework principal |
| Dart | 3.2+ | Linguagem |
| Supabase | 3.0+ | Backend (Auth + Banco + Storage) |
| go_router | 13.0+ | Navegação declarativa |
| youtube_player_iframe | 5.0+ | Player do YouTube |
| google_fonts | 6.0+ | Fontes personalizadas (Poppins) |
| intl | 0.19+ | Formatação de datas |

## Estrutura do Projeto

```
lib/
├── screens/
│   ├── splash_screen.dart      # Tela inicial com animação
│   ├── login_screen.dart       # Autenticação
│   ├── register_screen.dart    # Cadastro
│   ├── home_screen.dart        # Feed principal de vídeos
│   ├── detail_screen.dart      # Detalhes + player do vídeo
│   ├── favorites_screen.dart   # Lista de favoritos
│   ├── history_screen.dart     # Histórico com swipe-to-delete
│   └── profile_screen.dart     # Perfil com estatísticas
├── models/
│   └── video_model.dart        # Modelo de dados do vídeo
└── config/
    ├── app_router.dart         # Configuração de rotas
    └── supabase_config.dart    # Conexão com Supabase
```

## Como executar

### Pré-requisitos
- Flutter SDK instalado
- Editor (VS Code / Android Studio)
- Conta no Supabase

### Passo a passo

1. **Clone o repositório**
```bash
git clone https://github.com/Anavicaleixo/StudyFlex
cd StudyFlex
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Configure o Supabase**
   - Crie um projeto no [Supabase](https://supabase.com)
   - Execute os scripts SQL das tabelas (videos, favorites, history, users)
   - Atualize as credenciais no `supabase_config.dart`

4. **Execute o app**
```bash
flutter run
```

## Estrutura do Banco (Supabase)

| Tabela | Campos principais |
|--------|-------------------|
| `videos` | id, title, description, image_url, video_url, category, views, created_at |
| `favorites` | id, user_id, video_id, title, image_url, created_at |
| `history` | id, user_id, video_id, title, image_url, watched_at |
| `users` | gerenciado pelo Supabase Auth + metadata (name, bio, course, avatar_url) |

**Bucket Storage:** `avatars` (para fotos de perfil)

## Melhorias futuras

- [ ] Busca de vídeos
- [ ] Modo offline (cache de vídeos)
- [ ] Notificações push
- [ ] Compartilhamento de vídeos
- [ ] Avaliação/comentários

## Autor

**Anavicaleixo** – [GitHub](https://github.com/Anavicaleixo)

**Para salvar este README no seu projeto:**

1. No VS Code, crie um arquivo chamado `README.md` na **raiz do projeto** (mesma pasta onde está `pubspec.yaml`)
2. Copie todo o conteúdo acima
3. Salve o arquivo
4. Faça o commit:

```bash
git add README.md
git commit -m "docs: adiciona README completo do projeto"
git push
```

