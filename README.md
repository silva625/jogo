# De Casa em Casa — Roblox

Protótipo de reforma de casas inspirado na referência enviada: HUD escuro com detalhes rosa, dinheiro, XP, inventário e painel de missões.

## Abrir e jogar

1. No GitHub, abra [`build/DeCasaEmCasa.rbxlx`](build/DeCasaEmCasa.rbxlx) e clique em **Download raw file** (ícone de download). Alternativamente, use **Code → Download ZIP** e extraia o projeto.
2. No Roblox Studio (Windows ou macOS), use **File → Open from File**.
3. O bairro já aparece no editor. Clique em **Play** para receber uma das oito casas e iniciar as missões.
4. Aproxime-se dos objetos e segure **E**; no celular, use o botão de interação.
5. Recolha os 8 lixos, pinte as 4 paredes e coloque as 3 decorações. A ferramenta muda automaticamente conforme a etapa.
6. Use **B** ou o botão **Mochila** para ver as ferramentas. A barra inferior indica a ferramenta da etapa; não são Tools equipáveis nesta versão.

## Desenvolvimento na nuvem

Use o checkout existente em `/workspace/jogo`. Não é necessário criar worktrees.

```bash
cd /workspace/jogo
/workspace/tools/luau/luau tests/mission.luau
python3 tests/map.py
python3 scripts/build_map.py # Regerar o cenário após alterar o gerador
/workspace/tools/rojo/rojo build default.project.json -o /workspace/artifacts/DeCasaEmCasa.rbxlx
```

Ferramentas: Rojo 7.6.1 e Luau 0.699, instalados em `/workspace/tools`. O script de instalação reutilizável fica em `/workspace/setup-jogo.sh` e na configuração do ambiente. Não há pacotes npm, credenciais, serviços externos ou banco de dados necessários.

O servidor distribui as oito casas e valida dono, distância, etapa e ações duplicadas. Ao sair, a casa é restaurada para o próximo jogador. O módulo `Mission` concentra as regras testáveis. `Hud.client.luau` gera a interface e oculta localmente o telhado ao entrar. O bairro é gerado por `scripts/build_map.py` e salvo em `src/map/Neighborhood.rbxmx`, com peças nativas e sem assets externos.

O mapa inclui rua, calçadas, praça, postes, árvores, colinas, cercas e jardins. Cada casa tem varanda, telhado, chaminé, floreiras, sala e bancada de cozinha. A iluminação usa atmosfera e correção de cor. As janelas são decorativas nesta versão.

## Validação

Verificados na nuvem: compilação sintática dos quatro arquivos Luau, testes das regras e geração do arquivo de lugar com Script, LocalScript e ModuleScript.

Pendente no Studio: executar Play e completar a reforma; testar reset do personagem, dois jogadores e o Device Emulator. O Studio não está disponível neste ambiente Linux, portanto o runtime Roblox e o visual não foram validados aqui.

## Limites desta primeira versão

- Um bairro com oito casas e três etapas de reforma por jogador; sem demolição, loja ou minimapa. Configure o máximo de jogadores como **8** nas configurações do jogo no Roblox; o protótipo recusa jogadores adicionais quando todas as casas estiverem ocupadas.
- Dinheiro e XP duram a sessão. Não há DataStore nem compras com Robux.
- O telhado fica invisível apenas para o jogador que entra na casa. O cenário ainda usa peças simples e precisa de revisão visual no Studio.
- Ao sair e entrar novamente, a missão começa de novo. “Continuar explorando” fecha a tela de conclusão.

Publicar o jogo no Roblox é uma etapa separada, feita pelo dono no Studio após os testes.
