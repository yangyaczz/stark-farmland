<picture>
  <source media="(prefers-color-scheme: dark)" srcset=".github/mark-dark.svg">
  <img alt="Dojo logo" align="right" width="120" src=".github/mark-light.svg">
</picture>

<a href="https://twitter.com/dojostarknet">
<img src="https://img.shields.io/twitter/follow/dojostarknet?style=social"/>
</a>
<a href="https://github.com/dojoengine/dojo">
<img src="https://img.shields.io/github/stars/dojoengine/dojo?style=social"/>
</a>

[![discord](https://img.shields.io/badge/join-dojo-green?logo=discord&logoColor=white)](https://discord.gg/PwDa2mKhR4)
[![Telegram Chat][tg-badge]][tg-url]

[tg-badge]: https://img.shields.io/endpoint?color=neon&logo=telegram&label=chat&style=flat-square&url=https%3A%2F%2Ftg.sumanjay.workers.dev%2Fdojoengine
[tg-url]: https://t.me/dojoengine

# Dojo Starter: Official Guide

The official Dojo Starter guide, the quickest and most streamlined way to get your Dojo provable game up and running. This guide will assist you with the initial setup, from cloning the repository to deploying your world.

Read the full tutorial [here](https://book.dojoengine.org/tutorial/dojo-starter).

---

## Contribution

This starter project is a constant work in progress and contributions are greatly appreciated!

1. **Report a Bug**

   - If you think you have encountered a bug, and we should know about it, feel free to report it [here](https://github.com/dojoengine/dojo-starter/issues) and we will take care of it.

2. **Request a Feature**

   - You can also request for a feature [here](https://github.com/dojoengine/dojo-starter/issues), and if it's viable, it will be picked for development.

3. **Create a Pull Request**
   - It can't get better then this, your pull request will be appreciated by the community.

Happy coding!



```
katana --disable-fee
sozo build
sozo migrate apply
```

```
sozo execute stark_farmland::systems::actions::actions spawn
sozo execute stark_farmland::systems::actions::actions plant -c 1
```

torii query graphql
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

cp -r manifests/dev/base manifests/dev/overlays

writes = [ "Tree", "TreeManager", "Player", "Land", "LandManager"]

sozo migrate generate-overlays


```
katana --disable-fee --allowed-origins "*"
sozo migrate apply
torii --world 0x7dc571ec1ea63b3a2e85c1e0730707972b198d8932f6f97d2402ef4f2a83be7 --allowed-origins "*"
```

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