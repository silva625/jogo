# De Casa em Casa — Roblox

Jogo de reforma em um bairro residencial: limpar, pintar e escolher móveis para transformar uma casa abandonada. Visual com materiais de madeira, alvenaria, telhas e vidro, iluminação de dia e cores naturais.

## Abrir e jogar

1. No GitHub, abra [`build/DeCasaEmCasa.rbxlx`](build/DeCasaEmCasa.rbxlx) e clique em **Download raw file**. Também é possível usar **Code → Download ZIP**.
2. Abra o arquivo novo no Roblox Studio, em **File → Open from File**. O bairro e a loja já aparecem antes do Play.
3. Clique em **Play**. Cada jogador recebe uma das oito casas e nasce na rua em frente a ela, olhando para a entrada. O reset usa o mesmo ponto de nascimento da casa.
4. Aproxime-se do lixo e segure **E** por 1,8 segundo para varrer e recolher. Depois de retirar os oito lixos, pinte as quatro paredes, segurando **E** por 2,4 segundos em cada uma.
5. Depois da pintura, use **B / Mochila**, escolha um item e sua cor, e segure **E** em um dos três pontos de decoração. Você começa com três plantas grátis.
6. Para comprar, caminhe até a **Casa & Cia**, no fim da rua. Entre pela abertura entre as vitrines e interaja com o **balcão**. As compras só são aceitas dentro da loja. **L** permite consultar o catálogo de qualquer lugar; a mochila pode ser usada na casa.
7. O catálogo tem planta, luminária, tapete, mesa, poltrona, estante, quadro com cavalete, vaso de flores e relógio. Cada item tem quatro opções de cor.
8. Trocar uma decoração devolve a anterior à mochila. É possível redecorar depois da conclusão, sem ganhar XP repetido pelo mesmo ponto.

## Personagem trabalhando

O personagem segura uma vassoura durante a limpeza, um rolo ao pintar e uma caixa ao decorar. Os gestos são **procedurais**. O servidor replica apenas o estado da ação e suas ferramentas; cada cliente calcula as poses a cada quadro, inclusive para os outros jogadores, com entrada e saída graduais. Há suporte por nome de articulação para R15 e R6, sem IDs de animação externos.

A interação preserva a velocidade e a direção de movimento. A pose é aplicada depois do Animator e restaurada antes do quadro seguinte, evitando acumular deslocamentos nas articulações. Soltar o botão, afastar-se, morrer ou trocar de personagem interrompe o trabalho. O servidor valida dono, proximidade, etapa e duração antes de recompensar.

Os gestos ainda precisam de ajuste visual no Studio, principalmente em avatares com proporções diferentes. Não são animações capturadas ou assets publicados no Animation Editor.

## Cenário

O bairro tem oito casas com telhados inclinados, sótãos fechados, calhas, varandas, chaminés, janelas com aberturas reais, caixas de correio, lixeiras e jardins. Há rua, calçadas, praça, árvores e colinas sobre terreno contínuo.

O projeto usa materiais nativos de 2022 e `LightingStyle = Realistic`, com horário fixo **17h15**, luz dourada, reflexos de ambiente, sombras suaves, raios solares discretos e névoa leve no horizonte. Varandas, interiores, postes e loja têm luzes quentes. Não há desfoque de profundidade aplicado durante o jogo.

No Play, o terreno plano e as colinas são substituídos por Terrain nativo com grama de cores mais naturais. As casas têm paletas de fachada diferentes, juntas nas telhas, venezianas de sótão, rodapés, cortinas, corrimãos, condutores de chuva, caminhos com juntas, cascalho e armários com puxadores, pia e torneira. As copas das árvores projetam sombras.

A qualidade final depende também do nível gráfico do cliente Roblox. No Studio, confira **Studio Settings → Rendering → Editor Quality Level** para avaliar o cenário no editor. Durante o jogo, confira a qualidade gráfica em **Esc → Settings**. Aumente aos poucos e observe o FPS; o projeto não força a qualidade máxima do dispositivo.

A **Casa & Cia** tem fachada, vitrines, entrada aberta, balcão, caixa registradora, prateleiras, latas de tinta, móveis expostos, iluminação interna, estacionamento e furgão parado. O telhado fica invisível localmente ao entrar em uma casa ou na loja para facilitar a câmera.

Foram removidos os elementos de fantasia: portais, ilhas, nuvens de peças, orbes, cristais, lua gigante e decorações surreais.

## Desenvolvimento na nuvem

Use o checkout existente em `/workspace/jogo`. Cada tarefa já é isolada; não crie worktrees.

```bash
cd /workspace/jogo
python3 tests/map.py
for test in tests/*.luau; do /workspace/tools/luau/luau "$test"; done
for source in src/server/*.luau src/client/*.luau src/shared/*.luau tests/*.luau; do
  /workspace/tools/luau/luau-compile "$source" > /dev/null
done
/workspace/tools/rojo/rojo build default.project.json -o /workspace/artifacts/DeCasaEmCasa.rbxlx
```

Rojo 7.6.1 e Luau 0.699 ficam em `/workspace/tools`. O script reutilizável é `/workspace/setup-jogo.sh`, também salvo na configuração do ambiente. Não são necessários pacotes npm, credenciais, serviços externos ou banco de dados.

O cenário é gerado por `scripts/build_map.py` em `src/map/Neighborhood.rbxmx`. Só execute o gerador quando quiser substituir a geometria gerada; preserve eventuais edições manuais no mapa. O módulo `Mission` controla as etapas, `Decorations` controla compras e inventário, `ShopRules` define a área de compra, `WorkRules` define as durações, `WorkAnimation` gera ferramentas e estado, e `WorkMotion` calcula poses suaves no cliente. `Landscape.server.luau` prepara o Terrain na inicialização, sem atualizar o terreno a cada quadro.

As prévias da loja ficam em cache: ganhar moedas não recria os modelos 3D, e a loja fechada não reconstrói seu catálogo durante as tarefas.

## Validação e limites

Verificados na nuvem: sintaxe Luau, regras das missões, dinheiro e inventário, trocas, área da loja, duração das interações, continuidade das poses, equivalência matemática da suavização em 30/144 FPS, retorno da pose no cancelamento, estrutura e geração do lugar. O teste de FPS verifica os cálculos, não mede desempenho real. O runtime Roblox não foi executado aqui.

Pendente no Studio: Play, limpar/pintar/decorar, conferir gestos e ferramentas em R15/R6, cancelar no meio, afastar-se, morrer/resetar durante a ação, verificar outro jogador vendo a animação; caminhar até a loja, entrar, abrir o catálogo pelo balcão, comprar e recusar compra fora da loja, testar mochila, troca de cores, câmera e Device Emulator.

- O Roblox Studio não está disponível neste ambiente Linux. Não há validação visual ou de física aqui.
- O mapa usa peças nativas, sem modelos fotorrealistas. O estilo está mais próximo de uma simulação residencial, mas ainda é um protótipo.
- Configure o máximo de jogadores como **8** no Roblox. Cada casa é restaurada quando seu dono sai.
- Dinheiro, XP, compras e decoração duram a sessão, sem DataStore ou Robux.
- A mochila comporta 30 unidades compradas e há três posições fixas de decoração por casa. Não há construção livre, demolição ou minimapa.

Publicar o jogo no Roblox é uma etapa separada, feita pelo dono no Studio após os testes.
