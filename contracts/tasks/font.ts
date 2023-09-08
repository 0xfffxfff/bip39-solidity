import { task } from "hardhat/config";

task("font", "Set Font").setAction(async (taskArgs, hre) => {
  const MnemonicPoem = await hre.deployments.get("SeedPoems");
  const MnemonicPoemArtifact = await hre.ethers.getContractAt(
    "SeedPoems",
    MnemonicPoem.address
  );

  // const bebasNeueOnlyLowercaseAndSpace =
  //   "data:application/font-woff2;charset=utf-8;base64,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";
  const italic =
    "data:font/woff2;charset=utf-8;base64,d09GMgABAAAAABa8AA8AAAAAMKwAABZkAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGk4bhnIcgwYGYAB0EQgKwgSzWgtYAAE2AiQDgSwEIAWMMweBRgwHGyEoIwM1ktTSRvaXCVQOqzwZryDFGANhoVAQXAjFzGTm4zY2bn/r24BAve2PHhkhyezwtM1/F81RZXAIAhYoYuKcYBTYYCYuxFqV63TR6Y8s93sdm/u9jW0m06b/dUSoGc9PqNlpZCAq9v7q2fcLIUGCQj7hScmFFJRAIRxIwSl1+k6yh7YWtNCade/elGdv3rRPe9smmciCrzj4+e77iZMjxQMIQrvU0iTA7jKeblr8+EV9/X9zpZ0sHKkSyjmQJc8oVI3a/UnmMpkcbFLMHBHliiiJ4XkCBSh7NabOtcLV6r4KU6FtH+osxIzUZgqze5fNFLqdxK0Sj6Nr0gILWlSaf0daKwggML4TGn+4Eg4RDKIVAqbrfUL0QsEMQSEm4aAtUQBIy44QQGkusp51edVVBvivV31jAb8hPmYAAL3c9YwFJIBQ+CQohATX8gsA+Lv+IyV0OeXXNwDT03eXrn8D9rvWG09eN+oBA25pO2mDOWyPCGhzXQKKps8bOXcyv18WW+PBh/xdMLW/cd/IlvH1l7Q2lJfC/dFhggGgZaAGwYRAAEBhoMQERCAEGrOnWOSX4MOReX6MEIvHyhSDMDcSCMegHbiAwEvHsVBXEGAuADlFeQqCweAPUUcZgjvbpMvdaydmAPDTLxxncsC8VFLGgZStI5dun7fr6FaxW5LP2tzRhhjg3IlakXZQdFBsUJwTyK+p0oHVX18DJL762htB6mtX82iQcWfPsxfZvayGi+G5HbMTdsQO7DAJFNEk8VWmQYoiJiMhmGovK/taInF1tYDCrsEUFGDxD/eG4ZEKFMIkFIImpM/ys3RgwqCYn6UFo/kRfdWyZjkMgD+qov+VXxyN0aljdcflyJB7LrrPbAEzcSYNt3//AXQmc+dAXzu1/6yF7TlijgJ0hOg76nIMajsi6PYoE8PNSYXBjH7NGd7YFH29dw1p480EJvOG7fKNgAqNwqTyGAjUr4HgjEWcCd7KCQDzCbB7ODQOoLa7aFAJ6GgTdOKVHR4yZIcR4uZqUPtlTFC0UxYjjSgWmwRFxXJxaakwtrtIJM4T22X2hGxPUr3PURfDs2cX6jNjU3P1sbmx5mhBaS+DsHATi/DidDFvDgNKlfZi04xgwAIIJjP6xLmcPlnvOhy7dbpPdn2ifOmzSGxsMBCSfuM0lY3VODOESNtXClKKrNwasOv1GgRAtDkOMJwdLGBjEVFJOQzCrJ6ZVbHJ4Wjln+seuFg5XalMVaQuG5RbWodPqQY5uXwp0eSe2hcf72DlUaWOtU8ffwUz8M2KS+IQA8tms0Cse2BKTO8gsBZS3yAkvqif2LrA1A//9PBwSuYibM4b8rhIraeQ0LCqsqIY+TZQoWLJyq+MR4jolkeB0VusTvOD/Ha9RvvfukDKRSnJqpizLq149l6Zwgbm7fi9FhNLAgjOwuIiFOpczZZyzV1p4TdFdTM+BRv2H+1T6pVbRFKZLtuP1fmLIdBTSTDjuoAXBADMmO44rjmGwiLj7EBZFHllPsUjhZmM3ftzEhrrhBjFI2U4Uzibo7U8IAwkJb1bO6or1xnVavGNmlFESuFyf9PwzRIJ4lL2tdgETH0EC2qzVFxn55DG6jwjHdmLu4SKhiMiYrE8HW4Z4/vNuk5mwgpFRSedEFYgpdB7IYBL4gc+iwSOpY+SHP5oOo0dj2IoVKHEjIpU7+J9jv6piAuwGDD7HgRePID//zOiBzW5+WuhfJL3vGmzwKXHwYjoNTHCXjlJM4ZMSmdBGy1jneme0o0pfoVBg4ijVJFnN+XXwtWk/YJKGW77i1KsxDBRksiAFkDlfn4dTbi3aPryE62BCE3VIb7nlN2vp6iVmxsu1T4NRolbFCEjRSMkW6Zqsi3RnSrju47FlmXfA/TT3rE/kvSDtR4D8GaEYbqDMIOFdQ7M5gqmJsikqBOADXHvlPaIzM7OxZ6/lpjPU45ShY3qW+cq2yOl4pxaOZC4JjFONivvLGbeUAbVp/xTo7XOf2w0k89b3WKsRBU+ewTG4YEzYctR+Zui7j6i1c0oBJPKA/Ku5dlxzsiu7Tg8tGlHFyeY7hu0N5wg8xq2uD6m2IGYtH8LTLaw4NdA5NAY8Ird7oO3ICrEhfxEYfMB2ig6B1eN91YYFB9OCxQzW67bzKwQKtWI2pSo18Je0Uk6+Lmw+Od6rBQDfMLMUWaGGlcU0dnIbtelIQt1FGjL930ellubtgL1gnEVeG968Yl9KEM2Xl/HlpltaDqMlQW26EmIpvV/PwtEOHD05YhvIoZN4gxi0XOzUdL3DV082/j3gEKKasIBbwUQNDwl/F+d9Q+inDVRnx3jA/aijTAAnYkJHjv4Z6BvrssznWCOK41nsyLexStMF+Uv7WBWgpE7C1jzqu5FXz2Uhp58xyGE7OSKfVzVi3PBTGV1xeciTLEXCdHq5KWrrvVRigL/vgcwEPwgqlBp1dAYElERlz5e8PfLfocHmqdGUIApPIX2xOhhIJ+YE2UYVrVkAojibPoy81yuGGAUMW8CnDneRy0fmw5s9LLKQSblTk6CwBiiXEiHBXaExSX918adtejQMtU2Q5hBZ0qtv48LU1H5vaPkzDL/uqWYdsCz0OZpBELYTa6GTiFangZiSyNjVXBtd9Pr7Uv31PncVKt1ErFdr69ZZzz5RvZXG/OQ9QXcGeJrS7ppJkX344Lzptrk4XEYm5fos/ntkk8d42wkGT8PtiYmFZRJ7BMZ4b9XQSGVpBfdKzvCjRyi+yZHk/Zjc/7i4jpVoQBVCvsjWxyN/BjiEpDG3sC06HhzJVRIojt/HhBNTvelBRGHZXBn0Rd4giyp/vdv+E4H3Ed2BJwRLAnfneuQNYayR6tX3DAz2nO5rCEH03GdtQva/HW94iEVer74xiifKsf+f4VHfL/8+9qYyP5I8DFvyjCjt9R5Ovx16Wah8PLnIRAcAn9bqavEKdl+DGvuMg2pxSEmkRNG9Thx7tb5RUraPkQx1YmNWFJXHu1NSfcWOrRb5N6c+LTqiFwx+UHZ15h4eL3AXqjPVQjugXmE8adQ1ZVtU6e481hs75d/E1jrrJ3hSW+jQpqKTO4NKOAatE2BnolJAx3Jbl9pKLeBM+sbUqsKs8vCbrMbwdjpRpc8SynCeZrCTFs2a3RLAv4GTXxx5xENIvOGeVKzi8NjA06wQo4hD+dWiUXKpMjKgOYw7To5V6Fta8VJlly2ox1kskEJnIGrTaxPHFUYzbGPjrucMCJ3/ibDYQRiLj0s70GIx+Lfr68UITw+ppZvj1aYSTmftY4cEsfApIIpti0rZZmUtxjMpvaPjVIqsvQZ3vZcfsCj1DSbW+PWBi1XKjbas61lwaWc/Dbw8WVHjymsJn92U11qnG60WjPGwRXJ1hU1yVq/VOh2q/WSu4MkTUOYKDpwLg0Y16aFwewXrAw+9jGDg7Ha0O9Ugg9o8rPBBUvEktP7H815u1j6GeHFyGMNmcjnjumKuqKuimhdpFyj2s8nzkwfOCUP9GkyJY6SWaVyI4aVosFNKoJBx3xAVQH6HWWI3/FnoH+d2XF0AfBrk+vU/hDFd9W6T3o8JYNC/ieFGaEQ0pPkmyUPCSqKzc00m2SmkuZvCCbew+LPeJKrOPXwbRKbo1CIaGNwUWxGWpiW2GM7LBAbZ9C3fvqhnhaolzhC8iRuk2SaWCAc3e/bpaLxoeIT2ZEaeYhbau0Qp6vUac8lgpECSb3+Cp+SLAbd2Hg7LhjjWfxH2nqaXnCycReKenf2vE/vwbDjJBkhn/e1HNNFpNW2lCYFayOCYvXd9na9p+cuj09EDBHY1PM49U5G2VlSVB7iCCgQFoYoTBJ5Z3JmQmFU/g/LlgFOqjy3N9RX1CkibuUZrj3eNNRP4xGRFBaXugcrSeLxylc9QtBQbjcTcQbHtpMkIZ87mDzTpnFlug1aaatCfT4tNsOwdmZi1OhcmJGUvp3TjMIJqHCdJ6fvV01a0ORgoUAolrXGaxi8Ckxlnwtx2eVAdy5LWb5YcQZFEB2sr/iLxNpIPFX+/khjMC6k+UsnHyt/haI4Lj14QfQlyBNiE9049vbG6juuFTwBOz12hhy3DtjQ50L+vnf7ElcZZurDHQXVORZO8ueBo7oOHSgso6gqP+rt/HbpF56fh6U8WdT6WABBSAZKNhxAi0daSN6c5N7wXmTbnRLyD1t+vNcm+L6PxCbk49h7G2uezi1quFtGXo5dakj7b+sVcBvfN8US2hsQIKTLVj0Y+oxNK+P+ChMy6oF8x/7hYUyZZQ3umGDZjRm/Vn8/LOVpE3cN9TcWt2X7DY4KHMgLdCbPVjmfLP9s22clVZcnxbhs3onLfgGjWOXWgSCLfrSjwTvCao1Pt0bpOp31NSM2K6nI9JBiaXGIGlIrsE91BdIyk3Y06AzCdmJk3oz0qU3X1O6gvhW9ptzet3ByQcnjixMb58p/mSgnzyupsMToIQdtndGhi47oyKupSbJS1Wvm7GpyvNHSMnN5HIlLGcGdgBmzhqkYxUpbYUilKXF8NCXeXs0W85NdkWBMUNowTubNcBqb4ow+U2dc3uLLOdkp2Ro9V6IONzY7myd21FpCFUd946dizPRZ+f8QuLXpDVfLt1rg/yzRZqFrAqKldTPUzzxcoYady7KSQ46cJK/Oo5PuAMewM5Nw3lsbq2+7MJq/p7l0F0EOv3eOEQf+f+RypD/+Tb0xo6gtM1GhdkvFb3fwyR6hwM/Q1LIjsUuNaf8dHQU2y59IFFkE8d+8vUfkAY8w+R/fvUsLgv54+xTLboEJ/NhLHNvg8VB84SQ5uX14zM5IRbC2L00CXpIp1wjRvII6Wt6CdV/LQeHB/yg9My7Pn1DWhZFxSSqnvJmUrhm614HBE7YV9RTdeVdW8dAu3s/w73+/4cBdnFg+4U5UDtgAnCzTdN7Y8aIhgcS63r0h2o6gqZNmftzBxz6YFs+l2xcFpQ/E0HR36JWqrOrY3Gm5X+P4xa7Q6aE9EordeOoWgJEyFJaEZndkGgMXc6yj5mdN+gJ3/vHMxMKyPYvAOFahOHgo7VCvkkdE3ckshgkMd/uUWeqPGfLHhrBKZPtTlT7DFJehKY0QDR1qL6Qo8SE+I9JFij2mEuNfdfFgGqsKQTNF9h3uESTmvGtbBVMEGr7QMOBjGXxfvb0KPf5MJfnjxM9q1fyt85VRp/vOLpYS4U7XG3E9DRfUY86qAi9bczWeMF5vTucQwXR8QTMSXaSyIqZyzDS3Waf6EHU0DPRnONPCwFTBSgnvhockO/GIQbzhG4/tj4dFsZQkdFG4Bye+CxdPIdAwQpD5oFwoNPmUPsvhzObrD630Fwb/QU/hCwzu9QTvFPorGRmnSdFOSrmA8fOu1xJoloD//GKtPHDFjIxjGRGN5VNfL86xgDit4CsZ/3QQRf/Q2vodpXNVcM6xfH9GnrR8D023RdnRsziaxigihuNESmjrD7JpaDM0czTftrsFu4miz97kpY7Y23Uxtzo8O8cZAa5rVVu1N+fQwbCC3okiWyn60E8aefvmF6zgBhG2VSn+SUDEVlSWt32CYXeFAWv7L9hGMCLqofw5Kwg7kBFIIF6MCPw5UPnXBZSnqLSwhEiRUiMXV1FMlVL24+k9wMGKPDyUkJhKElZ67RT2wd3D9FUY9sfeqg8WDgRsl07kEsw4sQvjJ88NEcGwFRYWzTgO3geCBIHygVKoFsrvgWlanWy1NHUEZkgqyFd5NsfIiwtaPOY4tz5+LktVHf/Rk1S11f6OmKD4eV8Ng4pUaZajyWXPV2t0slWy1ChZbxXPLkEQrBR9BsPZ/jZmvps0G5uSFRFeprEgOU+tTv4rWLWAT+Ol9Bq5TGvYfFFVWwoItjmBny0Hd2X6Donk9tv8kmfA+o6sGjWCb3CsaXNwTb2/zRo2Jb/Tyc6vHENo78bfuuCKJGW10rxIK3S9Yt4VlAFVihJl1T+qGp7w8f3kyyK14VhUlqpeEIflWXMaQQvzlN4NMsn2u+yuAA19kq4J6vltH7uvOHtck91kUUbAB2jiH8ghPnU8kKL+bx9fKwow/LD0TNpIigzu5HagaFxGabLEWn2yNWnQsGn2ykXnpi8GI9jEdmmJ6bnRaKrJKC63WcIeyYI/zuBckvvbgvi2LGevxpkxVdFsSc6yyA/86mWJ69NZ4qulwty80VOz1+v4EOMaHAzmHxfIoE8/ZnDwI6ua1KjVKTMsBUDfWnxybS8TMawQTGvzXCSIo/+TdMpXjIT3Y7B5slBzFucLfn/H0cGz+l8b8xQ5annMsFCbE56aaSgJE43+wsZDCvhSf9w+sCJu8SKz6KCS+LRTewZ43zm9wtu2iaCm/8tkP147qArNMtkdUW5lTgAC89XzZKUkKklbz4U7TZFORXGPj9Qsbw6vsefmRkTodOqCiMawsT8HKz82abXV9ob8Uk/svQDieaABhFOAW+wcRuvIemiAAzAAQEDfS161duLvL7FU60v5SNibcJ4M7ToXgpR/NCL/AAB8M91zEQDg51mX+dXVVxH11vADGAkAAACAgONU4dT/Bz4v+BZaaFwGicgDGTpBO76m9wDobz/LldgkERQKsHjw4+jUbO1t8A9jDAKCvE7Mu4QJxgwySSUAukwhytmeA9+DMpku0r4ePUVeUhlkqS7WnOnbWdObYR0AcQbv2VttnVpRDeX7DomonMB76tYm5VY/qHXUAdrYyqIARrwIvpTPotVJZaFaucMQRi2G4TowItBYjBJbiDGsTRgnsp+S4LyAKRrvYobCXy15OWYt9/LGfOosgYAmFADgQvZmGCKvRgzj1XiMSKwBjNLXRYxR168YF1JPMUk9BGBK6hCHGeahd2AeZsMN27P5bJOhb0EDa7Br//KN+TKdXHZjzzcUDW1Zwyh/0xCL6U+BCW/3nRn9TWtqTt/V3Nc4ztflb+xp6bIISbVqjDUMhPxmAHmbY8zR0TH246kt7DtpUexafUqv5M/BFTnq3lf+e+hzcBn9bW1jObU/qvlfRNAKEelcUQ2IoYI9tJYq3tzYZ1mrBF94RP4EQLLassY6JLM01/UN+cUd5V/Gq8boXI5xgmQ+C/f7CaPGwo5irrEvmRuJ/Kdm8F7f6DVS61iY5WK+9SBdF7+Jevi069CHYxUtRgJOmQ6tOJmcONka9Wg0RpexWnCK9OjSqVWzPhyHfn06dOnRi2MCcwP1n5RPZmHRzrf1Wv2amDXrMoZFF296o3F8WIRG2rJjlkHrbLYnhlUYHpYLIYymzRxuFj2PtrYr0iZTCzuYJYqnIaBWruVerfNjvi0tuGEaC82ztZIjtKdm6NfW2VioBjIjOY0IrIU0Af3kjNBMGgJjbWkEM+9jUSvzKYhlIQTV0dKd0MbGw4HSpa0SZtrK4L1aS9aPREIFqmStnDyXCx3z71cL1OriRpH1kgc3ksHVPyRBAvOmjY6OXoQmYGrjTQq2iENyh+Jua32ScaTwXs2mTv02vZdZL0yImaiD36JQFtf+bQoDr2/9/OlOVpdaxJqWDz8wQGTIlCVbjlx58rm4FShUpFiJUmU8vMpVqFSlWo1a3/opCIRCGIRDBERCFERDDMRDC/ZcLqTtoo3of/dlOaNjHpxWZ+zZbZhvLCvJpzrHlq6+lYgm3jqu2THxcWNt4OPv857L6zmb6BIA";
  await MnemonicPoemArtifact.setFont(italic);

  console.log("All Done!");
});