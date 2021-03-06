package org.jetbrains.ruby.codeInsight.types.signature

import java.util.*

class RSignatureContractContainer {

    private val myContracts: MutableMap<MethodInfo, RSignatureContract>
    private val myNumberOfCalls: MutableMap<MethodInfo, Int>

    init {
        myContracts = HashMap()
        myNumberOfCalls = HashMap()
    }

    fun acceptTuple(tuple: RTuple): Boolean {
        val currInfo = tuple.methodInfo

        val contract = myContracts[currInfo]
        return contract != null && tuple.argsInfo == contract.argsInfo && SignatureContract.accept(contract, tuple)
    }

    fun addTuple(tuple: RTuple) {
        val currInfo = tuple.methodInfo

        if (myContracts.containsKey(currInfo)) {
            val contract = myContracts[currInfo]

            if (tuple.argsInfo.size == contract?.argsInfo?.size) {
                contract.addRTuple(tuple)
                myNumberOfCalls.compute(currInfo) { _, oldNumber -> (oldNumber ?: 0) + 1 }
            }
        } else {
            val contract = RSignatureContract(tuple)
            myContracts.put(currInfo, contract)
        }
    }

    val registeredMethods: Set<MethodInfo>
        get() = myContracts.keys

    fun getSignature(info: MethodInfo): RSignatureContract? {
        return myContracts[info]?.let {
            it.minimize()
            it
        }
    }

    fun clear() {
        myContracts.clear()
    }
}