# De Casa em Casa — Roblox

Protótipo de reforma de casas inspirado na referência enviada: HUD escuro com detalhes rosa, dinheiro, XP, inventário e painel de missões.

## Abrir e jogar

1. No GitHub, abra [`build/DeCasaEmCasa.rbxlx`](build/DeCasaEmCasa.rbxlx) e clique em **Download raw file** (ícone de download). Alternativamente, use **Code → Download ZIP** e extraia o projeto.
2. No Roblox Studio (Windows ou macOS), use **File → Open from File**.
3. Clique em **Play**. Cada jogador recebe sua própria casa.
4. Aproxime-se dos objetos e segure **E**; no celular, use o botão de interação.
5. Recolha os 8 lixos, pinte as 4 paredes e coloque as 3 decorações. A ferramenta muda automaticamente conforme a etapa.
6. Use **B** ou o botão **Mochila** para ver as ferramentas. A barra inferior indica a ferramenta da etapa; não são Tools equipáveis nesta versão.

## Desenvolvimento na nuvem

Use o checkout existente em `/workspace/jogo`. Não é necessário criar worktrees.

```bash
cd /workspace/jogo
/workspace/tools/luau/luau tests/mission.luau
/workspace/tools/rojo/rojo build default.project.json -o /workspace/artifacts/DeCasaEmCasa.rbxlx
```

Ferramentas: Rojo 7.6.1 e Luau 0.699, instalados em `/workspace/tools`. O script de instalação reutilizável fica em `/workspace/setup-jogo.sh` e na configuração do ambiente. Não há pacotes npm, credenciais, serviços externos ou banco de dados necessários.

O servidor cria as casas e valida dono, distância, etapa e ações duplicadas. O módulo `Mission` concentra as regras testáveis. `Hud.client.luau` gera a interface. Os objetos do cenário são construídos com peças nativas; não há assets externos.

## Validação

Verificados na nuvem: compilação sintática dos quatro arquivos Luau, testes das regras e geração do arquivo de lugar com Script, LocalScript e ModuleScript.

Pendente no Studio: executar Play e completar a reforma; testar reset do personagem, dois jogadores e o Device Emulator. O Studio não está disponível neste ambiente Linux, portanto o runtime Roblox e o visual não foram validados aqui.

## Limites desta primeira versão

- Uma casa com três etapas e decoração simples; sem demolição, loja ou minimapa.
- Dinheiro e XP duram a sessão. Não há DataStore nem compras com Robux.
- O cenário é um protótipo com teto aberto para a câmera. Ainda não reproduz os modelos e a iluminação da imagem.
- Ao sair e entrar novamente, a missão começa de novo. “Continuar explorando” fecha a tela de conclusão.

Publicar o jogo no Roblox é uma etapa separada, feita pelo dono no Studio após os testes.
