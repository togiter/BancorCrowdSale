<<template>
    <div class="operate">
        <p><input type='text' v-model='newOwner' /><button @click = 'transerOwnership'>转让代币权</button></p>
        <p><button @click = 'acceptTranserOwnership'>接受并确认代币权</button></p>
        <p><input type='number' v-model='ethAmount' /> <button @click="returnToken">eth兑换</button></p>
        <p><input type='text' v-model='addr' /><button @click='balanceClicked'>查询</button></p>
    </div>
</template>

<script>
import {web3ComputeReturn,web3ContributeETH,web3AcceptTokenOwnership} from "@/web3js/crowdsale/crowdsale.js";
import {web3TransferOwnership,web3AcceptOwnership,web3Balance} from "@/web3js/smarttoken/smarttoken.js";
export default {
    data() {
        return {
            addr:'',
            ethAmount:'',//以太坊的兑换数量
            newOwner:'',
        }
    },
    created() {
    },
    methods: {
         returnToken(){
        web3ContributeETH(this.ethAmount);
    },
    balanceClicked(){
        web3Balance(this.addr);
    },
    transerOwnership(){
        web3TransferOwnership(this.newOwner);
    },
    acceptTranserOwnership(){
        web3AcceptTokenOwnership();
    }

    },
}
</script>
<style>
input{
    border-color: gainsboro;
    border-width: 1px;
}
</style>
