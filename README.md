<picture>
  <img alt="logo" align="right" width="40" src="./plan/logo.png">
</picture>


# Stark-Farmland

![ui](./plan/UI.png)
- Frontend: <https://github.com/yangyaczz/stark-farmland-react/>

- Slot katana : <https://api.cartridge.gg/x/farmlandtest/katana>
- Slot torii: <https://api.cartridge.gg/x/farmlandtest/torii>

## Introduction
Stark-Farmland is a multiplayer online game where players cultivate their virtual farms, interact, and trade with others. Expand your empire, disrupt or aid fellow farmers, and blur the lines between virtual and real with actual fruit rewards from successful harvests! 
 

## Code

- program and test with below code and change the variable in [Scarb.toml](./Scarb.toml) [tool.dojo.env]
  ```
  katana --disable-fee
  sozo build
  sozo test
  sozo migrate apply

  sozo execute stark_farmland::systems::actions::actions spawn
  sozo execute stark_farmland::systems::actions::actions plant -c 1
  ```

- query graphql with torii <http://localhost:8080/graphql>

  ```
  query {
    playerModels {
      edges{
        node{
          player
          is_spawn
          seed_amount
        }
      }
    }
    treeModels {
      edges{
        node {
          id
          player
          is_fruited
        }
      }
    }
  }
  ```

- prepare to interact with frontend 
  ```
  cp -r manifests/dev/base manifests/dev/overlays

  // modify the write
  writes = [ "Tree", "TreeManager", "Player", "Land", "LandManager"]

  // or
  sozo migrate generate-overlays
  ```



- run for frontend
  ```
  katana --disable-fee --allowed-origins "*"
  sozo migrate apply
  torii --world 0x7dc571ec1ea63b3a2e85c1e0730707972b198d8932f6f97d2402ef4f2a83be7 --allowed-origins "*"
  ```

- deploy on slot

  ```
  slot auth login
  slot deployments create farmlandtest katana

  modify [tool.dojo.env] rpc

  slot deployments logs farmlandtest katana -f

  modify [tool.dojo.env] ac and pk

  sozo build
  sozo migrate plan
  sozo migrate apply

  slot deployments create farmlandtest torii --world 0x7dc571ec1ea63b3a2e85c1e0730707972b198d8932f6f97d2402ef4f2a83be7 --rpc https://api.cartridge.gg/x/farmlandtest/katana --start-block 1

  slot deployments logs farmlandtest torii -f
  ```