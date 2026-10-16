# Entrelinhas — instalação do zero

Biblioteca de EPUB e PDF com cadastro por e-mail e senha. Cada usuário tem sua própria biblioteca no Supabase. Livros, capas e posição de leitura são associados à conta. A configuração real da sua conta precisa ser feita nos painéis do Supabase e Netlify; o pacote não contém suas chaves.

## 1. Criar a conta e o projeto no Supabase

1. Entre em https://supabase.com/dashboard e crie sua conta ou entre na existente.
2. Clique em New project, escolha/crie uma organização e nomeie o projeto (por exemplo, entrelinhas).
3. Escolha uma senha forte para o banco e guarde-a. Ela não é a senha dos leitores e não será colocada no Netlify.
4. Escolha uma região próxima e um plano adequado. Aguarde a criação do projeto.
5. Se já houver um projeto com livros ou usuários, não o exclua. Criar outro projeto começa uma biblioteca separada, sem migrar dados.

## 2. Criar tabela, buckets e regras

1. Extraia este ZIP no computador.
2. No Supabase, abra SQL Editor > New query.
3. No computador, abra supabase/schema.sql com Bloco de Notas ou outro editor de texto.
4. Copie TODO o conteúdo do arquivo, cole no SQL Editor e clique em Run. Não cole apenas o nome ou caminho do arquivo.
5. A mensagem Success. No rows returned. indica que os comandos rodaram sem retornar uma lista de dados.
6. Em Table Editor, confira a tabela public.books.
7. Em Storage, confira os buckets ebooks e covers. Ambos devem continuar privados.
8. O script ativa RLS e cria regras que associam registros e arquivos ao ID do usuário autenticado. Não desative essas regras para resolver erros.

## 3. Copiar URL e chave do mesmo projeto

1. No painel do projeto, abra Connect para localizar Project URL. Se necessário, procure-a em Project Settings > Data API.
2. Em Project Settings > API Keys, copie a Publishable key.
3. Guarde os dois valores para cadastrar no Netlify. A URL e a chave devem ser do mesmo projeto onde você executou o SQL.
4. Não use Secret key, service_role ou a senha do banco neste site. Não envie senhas pelo chat.
5. O app já carrega a biblioteca JavaScript do Supabase. Não é necessário instalar @supabase/ssr para este projeto.

## 4. Enviar o código ao GitHub

1. Entre em https://github.com e crie um novo repositório, por exemplo entrelinhas. Pode ser privado.
2. Depois de extrair este ZIP, localize os arquivos package.json, netlify.toml e README.md, e as pastas public, scripts e supabase.
3. No repositório, escolha Add file > Upload files (ou uploading an existing file em um repositório novo).
4. Envie ESSES ARQUIVOS E PASTAS, de forma que package.json e netlify.toml fiquem visíveis logo ao abrir o repositório.
5. Clique em Commit changes para salvar os arquivos.
6. Não envie só o ZIP para o repositório. Não coloque o projeto dentro de uma pasta extra.

A raiz do repositório deve conter:

- package.json
- netlify.toml
- README.md
- public/ (incluindo index.html, app.js, favicon.svg e assets/)
- scripts/ (incluindo build-netlify.mjs)
- supabase/ (incluindo schema.sql)

## 5. Conectar o Netlify ao GitHub

1. Entre em https://app.netlify.com e crie uma conta ou entre na existente.
2. Escolha Add new project > Import an existing project > GitHub.
3. Autorize o Netlify a acessar o repositório escolhido e selecione-o.
4. Se ele não aparecer, use Configure Netlify on GitHub e conceda acesso a esse repositório. Volte e atualize a lista.
5. Para esta estrutura de arquivos, deixe Base directory VAZIO.
6. Configure Build command como npm run build.
7. Configure Publish directory como dist.
8. O netlify.toml do pacote também declara esses valores. O Netlify gera dist durante o build; você não precisa enviar dist ao GitHub.

## 6. Variáveis de ambiente

Antes de iniciar o deploy, procure a seção Environment variables. Se o projeto já estiver criado, use Project configuration > Environment variables.

Adicione uma variável por vez (Add a single variable):

| Nome exato | Valor |
| --- | --- |
| SUPABASE_URL | Project URL copiada do Supabase |
| SUPABASE_PUBLISHABLE_KEY | Publishable key do mesmo projeto |

Use os valores sem aspas. Certifique-se de que as variáveis estejam disponíveis no build de produção. Não use nomes NEXT_PUBLIC_ ou VITE_ neste pacote: o script usa exatamente os nomes acima.

Depois, inicie o deploy. Se ele já ocorreu antes de salvar as variáveis, faça um NOVO deploy.

Não arraste este ZIP de código-fonte para Netlify Drop: deploy manual não executa o build. Este guia usa a conexão ao GitHub para o Netlify executar npm run build e gerar config.js.

## 7. Conferir o deploy e a visibilidade

1. Aguarde a publicação de produção aparecer como Published.
2. Abra seus detalhes em Deploys ou clicando na linha da publicação em Atividade.
3. Em Deploy File Explorer, na raiz publicada devem existir index.html, app.js e config.js, além da pasta assets.
4. Abra o endereço de produção terminado em .netlify.app, sem acrescentar nomes de pastas ou /public.
5. Se o projeto estiver privado no Netlify, outras pessoas não poderão chegar à tela de login. Para permitir isso, use Tornar público / Make public. Isso permite a qualquer pessoa com o endereço abrir o site; os livros continuam sujeitos ao login e às regras de acesso do Supabase.
6. Não torne os buckets ebooks e covers públicos.

## 8. Endereço do site no Supabase

1. Copie o endereço de produção do Netlify, incluindo https://.
2. No Supabase, abra Authentication > URL Configuration.
3. Defina Site URL como o endereço de produção que você copiou.
4. Em Redirect URLs, adicione esse mesmo endereço e salve.
5. Em Authentication > Sign In / Providers, confira se o provedor Email está habilitado e se novos cadastros são permitidos.
6. Se confirmação de e-mail estiver habilitada, os leitores precisarão confirmar o cadastro pelo e-mail antes de entrar. Configure o envio de e-mails/SMTP conforme as necessidades e limites do seu projeto antes de ampliar o uso.

## 9. Testar a biblioteca

1. Abra o site e clique em Criar uma conta. Use e-mail e senha; os leitores não precisam de contas no Netlify, GitHub ou painel do Supabase.
2. Confirme o e-mail se solicitado e entre.
3. Envie um EPUB ou PDF de teste de até 50 MB. Abra-o, avance e feche o leitor.
4. No celular, abra o mesmo endereço, entre com a mesma conta e confira o livro e a posição.
5. Em outro navegador ou janela anônima, crie uma segunda conta. A biblioteca deve começar vazia.
6. Confirme que o cadastro aparece em Authentication > Users no Supabase e que o livro aparece em public.books com user_id correspondente.

## Entender os erros

| Sintoma | Onde conferir |
| --- | --- |
| Página padrão 404 do Netlify | Endereço aberto, publicação de produção, pasta publicada e index.html na raiz. Essa página acontece antes de o app acessar o Supabase. |
| Build pede variáveis do Supabase | Environment variables e novo deploy após salvar |
| Site abre, mas mostra erro de chave/conexão | Project URL e Publishable key do mesmo projeto |
| Cadastro exige confirmação | Caixa de e-mail, configuração Email e envio de mensagens no Supabase |
| Link de confirmação vai para endereço antigo | Authentication > URL Configuration > Site URL |
| Erro ao listar/enviar livros | Tabela books, regras RLS, buckets ebooks/covers e sessão autenticada |

## Limites desta entrega

O pacote foi verificado localmente com uma configuração de exemplo; a integração com seu Supabase e a publicação real precisam ser testadas após os passos acima. O modo escuro e o tamanho de fonte ficam salvos por aparelho. Os ebooks, capas e progresso usam a conta no Supabase. Arquivos e contas de outros projetos não são migrados automaticamente. O app precisa de conexão para autenticação e sincronização; não prometa sincronização no instante em que o sistema fecha o navegador à força.
