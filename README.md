# De Casa em Casa — Roblox

Protótipo de reforma de casas inspirado na referência enviada: HUD escuro com detalhes rosa, dinheiro, XP, inventário e painel de missões.

## Entre Mundos: reforme o impossível

O bairro agora flutua sobre nuvens, com orbes animados, iluminação de crepúsculo e um portal para o **Observatório dos Sonhos**, uma ilha com lua gigante. Vá ao portal no fim da rua e segure **E** para viajar; use o portal da ilha para retornar.

Encontre **12 fragmentos de sonho**: nove no bairro e três no observatório. Cada um rende 100 moedas e 25 XP, uma vez por jogador na sessão. A coleção completa dá mais 750 moedas e um **Aquário de galáxia** grátis. O contador fica na tela; os cristais já coletados ficam apagados apenas para quem os coletou.

A categoria **Surreais** da loja inclui Aquário de galáxia, Árvore de estrelas e Lua de cabeceira. A reforma continua sendo a missão principal; explorar é uma forma alternativa de ganhar moedas e escolher mais decorações.

## Abrir e jogar

1. No GitHub, abra [`build/DeCasaEmCasa.rbxlx`](build/DeCasaEmCasa.rbxlx) e clique em **Download raw file** (ícone de download). Alternativamente, use **Code → Download ZIP** e extraia o projeto.
2. No Roblox Studio (Windows ou macOS), use **File → Open from File**.
3. O bairro já aparece no editor. Clique em **Play** para receber uma das oito casas e iniciar as missões.
4. Aproxime-se dos objetos e segure **E**; no celular, use o botão de interação.
5. Recolha os 8 lixos, pinte as 4 paredes e coloque as 3 decorações. A ferramenta muda automaticamente conforme a etapa.
6. Use **L / Loja** ou **B / Mochila** para abrir o catálogo. Compre um item, escolha uma das quatro cores e clique em **Escolher**. Depois da pintura, segure **E** em um dos três pontos rosa para colocar a decoração selecionada.
7. Você recebe **3 plantas grátis**. O catálogo também tem luminária, tapete, mesa, poltrona e estante. A aba **minha mochila** filtra itens comprados ou instalados. As prévias 3D mostram o modelo e a cor escolhidos.
8. Você pode trocar decorações mesmo depois de concluir a reforma. O item retirado volta à mochila; mudar sua cor não exige outra compra. Cada ponto dá XP apenas na primeira colocação. Os três pontos são fixos nesta versão.

## Desenvolvimento na nuvem

Use o checkout existente em `/workspace/jogo`. Não é necessário criar worktrees.

```bash
cd /workspace/jogo
/workspace/tools/luau/luau tests/mission.luau
/workspace/tools/luau/luau tests/decorations.luau
/workspace/tools/luau/luau tests/exploration.luau
python3 tests/map.py
python3 scripts/build_map.py # Regerar o cenário após alterar o gerador
/workspace/tools/rojo/rojo build default.project.json -o /workspace/artifacts/DeCasaEmCasa.rbxlx
```

Ferramentas: Rojo 7.6.1 e Luau 0.699, instalados em `/workspace/tools`. O script de instalação reutilizável fica em `/workspace/setup-jogo.sh` e na configuração do ambiente. Não há pacotes npm, credenciais, serviços externos ou banco de dados necessários.

O servidor distribui as oito casas e valida dono, distância, etapa e ações duplicadas. Ao sair, a casa é restaurada para o próximo jogador. O módulo `Mission` concentra as regras testáveis. `Hud.client.luau` gera a interface e oculta localmente o telhado ao entrar. O bairro é gerado por `scripts/build_map.py` e salvo em `src/map/Neighborhood.rbxmx`, com peças nativas e sem assets externos.

O mapa inclui rua, calçadas, praça, postes, árvores, colinas, cercas e jardins. Cada casa tem varanda, telhado, chaminé, floreiras, sala e bancada de cozinha. A iluminação usa atmosfera e correção de cor. As janelas são decorativas nesta versão.

## Validação

Verificados na nuvem: compilação sintática dos arquivos Luau, regras das missões, compras, saldo insuficiente, inventário, troca, cores, conclusão sem compras obrigatórias, proteção contra recompensa repetida e geração do arquivo de lugar.

Pendente no Studio: executar Play e completar a reforma; abrir loja, comprar, escolher cor, colocar e trocar móveis antes/depois da conclusão; testar saldo insuficiente, reset do personagem, dois jogadores e o Device Emulator. Conferir portal de ida/volta, coleta independente dos 12 cristais, recompensa da coleção, modelos surreais, orbes e iluminação. O Studio não está disponível neste ambiente Linux, portanto o runtime Roblox e o visual não foram validados aqui.

## Limites desta primeira versão

- Um bairro com oito casas, loja e três etapas de reforma por jogador; sem demolição ou minimapa. Configure o máximo de jogadores como **8** nas configurações do jogo no Roblox; o protótipo recusa jogadores adicionais quando todas as casas estiverem ocupadas.
- Dinheiro, XP, compras, cristais e decoração duram a sessão. Não há DataStore nem compras com Robux. Compras são bloqueadas quando a mochila tem 30 unidades; o presente da coleção pode ultrapassar esse limite. Os itens instalados ocupam os três pontos fixos da casa.
- O telhado fica invisível apenas para o jogador que entra na casa. O cenário ainda usa peças simples e precisa de revisão visual no Studio.
- Ao sair e entrar novamente, a missão começa de novo. “Continuar explorando” fecha a tela de conclusão.

Publicar o jogo no Roblox é uma etapa separada, feita pelo dono no Studio após os testes.
