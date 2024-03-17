import streamlit as st
import subprocess

st.header("Proof Generation")

col1, col2 = st.columns(2)

block = col1.number_input("Block", 0, step=1, key="block", placeholder="1337")

validator = col2.number_input("Validator Number", 0, step=1, key="validator", placeholder="42")

rpc = st.text_input("Execution RPC URL")

st.button('Generate proof', type="primary")
    # with st.spinner("Generating..."):
        # output = subprocess.check_output(["node", "script/validator.js", str(block), str(validator), rpc], cwd="../")
st.code('''{
    "proof": [
        "0x45e00b05d533d6f81849556f294ebdd81ad76c4eb5a95962c4e59473004592a3",
        "0x1407bff72a145b281bb56f77ee7b95aa4da712c4217ae264b1a5b7355cc7a498",
        "0xd97767b7239ddcd88d44f5f540a86bdaf1d6e3cda37b310a2ff1e1acfd15ee78",
        "0x547fe2efc34dcb49a46e50f455ce5519f88474efd0a953f33c84602e7570a78d",
        "0x12ece42dc5bcc4a3434472bdacb87e67c26a3c7f441dbbaf462df55c60dd96f1",
        "0x7b289597dedfc74806f4c4a9900108f82098be23be5abd3c255174da80d08c2a",
        "0x86fed5417c1db4e7afc18d63e348f1ea18b63f7ca178910648dbae279d70f8d8",
        "0xdcb2584ba6e7640c92c2fa7a7d8e954c71b6a4eb60f0a343decac4a910666648",
        "0x418f38488bfb2f734bc1f3eba5367baeea3bb6d9fa0caf46d8189a1896f96fd4",
        "0xa67960b8dd96c69a132cef9e8dcbd090768144205cb7518a42504e70dca7b49b",
        "0xb74848839b9813d4b9a54d440492be51b34528b04ee74c1b3a960dbcd65bbd0c",
        "0x68128f493b8821f25b5a6d6aee54e93520bf10400b3617d4e6cab074875ef20a",
        "0x38daf6bda652ab12cf3ea82fe0634cb2da035fd4835660df804718ba6dbddbae",
        "0x98a370857e38f0d6404c7fc0d09fbb3e9d16f9cab509391bf6de011767ac4d50",
        "0x384e03eedc089a2c38e31448ef4746001d987bd91d46df2bb772ca288364e414",
        "0x3eb4c6944dbb8aacdd44b7774f7f5112bb5db5699dd81936417777715e51bce8",
        "0x6437690f1f5c121fdac4984687ca6caddd871024b5f347420eb16ab356dd7597",
        "0x7449588dcdaf0bb2b4db211b2026e609ee92e49c1af2f9c115614ab102e87f78",
        "0x6ead821f132b3e69d9753ef42526e80aa609d91c8b7f166cf061522ba10ac2c3",
        "0x02e79355fd3ef9461441adc378aaf33a644d2aa53c5dbbc3109e9a7df0ca29a8",
        "0xc1866e4d2fb0335ccea4c36e3fb6e1381942fc1c388e828a6f9cabd393fa524f",
        "0x8a8d7fe3af8caa085a7639a832001457dfb9128a8061142ad0335629ff23ff9c",
        "0xfeb3c337d7a51a6fbf00b9e34c52e1c9195c969bd4e7a0bfd51d5c5bed9c1167",
        "0xe71f0aa83cc32edfbefa9f4d3e0174ca85182eec9f3a09f6a6c0df6377a510d7",
        "0x31206fa80a50bb6abe29085058f16212212a60eec8f049fecb92d8c8e0a84bc0",
        "0x21352bfecbeddde993839f614c3dac0a3ee37543f9b412b16199dc158e23b544",
        "0x619e312724bb6d7c3153ed9de791d764a366b389af13c58bf8a8d90481a46765",
        "0x7cdd2986268250628d0c10e385c58c6191e6fbe05191bcc04f133f2cea72c1c4",
        "0x848930bd7ba8cac54661072113fb278869e07bb8587f91392933374d017bcbe1",
        "0x8869ff2c22b28cc10510d9853292803328be4fb0e80495e8bb8d271f5b889636",
        "0xb5fe28e79f1b850f8658246ce9b6a1e7b49fc06db7143e8fe0b4f2b0c5523a5c",
        "0x985e929f70af28d0bdd1a90a808f977f597c7c778c489e98d3bd8910d31ac0f7",
        "0xc6f67e02e6e4e1bdefb994c6098953f34636ba2b6ca20a4721d2b26a886722ff",
        "0x1c9a7e5ff1cf48b4ad1582d3f4e4a1004f3b20d8c5a2b71387a4254ad933ebc5",
        "0x2f075ae229646b6f6aed19a5e372cf295081401eb893ff599b3f9acc0c0d3e7d",
        "0x328921deb59612076801e8cd61592107b5c67c79b846595cc6320c395b46362c",
        "0xbfb909fdb236ad2411b4e4883810a074b840464689986c3f8a8091827e17c327",
        "0x55d8fb3687ba3ba49f342c77f5a1f89bec83d811446e1a467139213d640b6a74",
        "0xf7210d4f8e7e1039790e7bf4efa207555a10a6db1dd4b95da313aaa88b88fe76",
        "0xad21b516cbc645ffe34ab5de1c8aef8cd4e7f8d2b51e8e1456adc7563cda206f",
        "0x42bb130000000000000000000000000000000000000000000000000000000000",
        "0x00a4140000000000000000000000000000000000000000000000000000000000",
        "0x6840c55f7a56f12078964163f9b37ae34f4a0d700f07f171af5be8eca1da01e8",
        "0xf3f1ae3000b90cd6d8e38aa33f6015334e9d7fa561092ac99ef56d8681e17c9e",
        "0x3d763c0360a2fd252caf20a2cb3183a159ee9b08d456eaadbda87dc32c88ede1",
        "0xebd2bfdcf4e21c8b620175ad835afbfb9883c5eb8b2b7dfdd1fa33bdf25c8e09",
        "0x4bbe5a642d187eac4e02a5015b77246ba21cb61a7dcc666c5ac998fab4d34a4e",
        "0x4f3b879ec3e80c54172b1d92860ee69e231d79e0359190f38d991b7149a68b58",
        "0x6205fc26953f571dc26da9aa645a07363cbf08f37c448ffd320349ff72a029b8"
    ],
    "validator": {
        "pubkey": "0x8efba2238a00d678306c6258105b058e3c8b0c1f36e821de42da7319c4221b77aa74135dab1860235e19d6515575c381",
        "withdrawal_credentials": "0x00ea42f2e2c8e339759f42e72b2f6801485abfdfbd416f0ffdd1d1b07b33a9c0",
        "effective_balance": 32000000000,
        "slashed": false,
        "activation_eligibility_epoch": 0,
        "activation_epoch": 0,
        "exit_epoch": 18446744073709551615,
        "withdrawable_epoch": 18446744073709551615
    },
    "validatorIndex": 10,
    "blockRoot": "0x94709fbcb7e8b3c3b2219e3e7bbcfa56708e4c56a4a70ab39bc74eeff4090c69",
    "timestamp": 1710623075,
    "gI": 798245441765386
}''', "json")