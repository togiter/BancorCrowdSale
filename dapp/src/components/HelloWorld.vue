<template>
  <div class="hello">
    <button @click="returnToken">兑换</button>
     <button @click="gotoWallet">钱包</button>
  </div>
</template>

<script>
//import {web3ComputeReturn} from "@/web3js/crowdsale/crowdsale.js";
import "@/wallet/wallet-hd.js";
export default {
  name: 'HelloWorld',
  data () {
    return {
      msg: 'Welcome to Your Vue.js App'
    }
  },
  created() {
    console.log('starting');
    window.wallet.generateMaster('111111');
  },
  methods: {
    returnToken(){
      this.$router.push({
        path:"/operate"
      });
      },
      gotoWallet(){
         this.$router.push({
        path:"/walletOP"
      });
      }

  },
  
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h1, h2 {
  font-weight: normal;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
