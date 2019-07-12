<template>
    <div class="wallet">
        <el-form class="op">
            <el-form-item label="助记词">
                <el-input v-model="mnemoinc" placeholder="助记词生成"></el-input><el-button @clicked = "genMnemoinc">生成助记词</el-button>
            </el-form-item> 
             <el-form-item label="主节点">
                 <el-input v-model="account" placeholder="生成钱包"></el-input><el-button @clicked = "genWallet">生成钱包</el-button> 
             </el-form-item>
        </el-form>
    </div>
</template>

<script>
import "@/wallet/wallet-hd.js";
export default {
    data() {
        return {
            mnemoinc:'',
            account:'',
        }
    },
    created() {
        
    },

    methods: {
        genMnemoinc(){
            console.log('mne');
            this.mnemoinc = window.wallet.generateMnemonic();
        },
        genWallet(){

        }
    },
}
</script>
<style scoped>

</style>
