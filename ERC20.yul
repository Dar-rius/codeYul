object "Token"{
    code {
        sstore(0, caller())

        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))
    }

    object "runtime"{
        code {
            sstore(0, 0)
            sstore(1, 0x0000000000000000000000000000000000000000)

            // calcul du stockage de la balance c'est:
            // slot = keccak256(abi.encode(slot))

            //Selector of slot to return the value
            function selector(data, owner) -> result{
                switch data
                    case "name" {result := calldataload(0x10)}
                    case "symbol" {result := calldataload(0x20)}
                    case "decimals" {result := calldataload(0x30)}
                    case "totalSupply" {result := calldataload(0x40)}
                    case  "balance" {result := calldataload(div(owner, 0x50))}
                    default {revert(0,0)}
            }

            function selectSlot(data, owner) -> result{
                switch data
                    case "name" {result := 0x10}
                    case "symbol" {result := 0x20}
                    case "decimals" {result := 0x30}
                    case "totalSupply" {result := 0x40}
                    case  "balance" {result := div(owner,0x50)}
                    default {revert(0,0)}
            }

            function emitEvent(from, to, amount){
                log3(0x80, 0x88, from , to, amount)
            }

            //Initialize contract
            function initialize(name, symbol, decimals, totalSupply){
                if lt(sload(0), 1){
                    sstore(0x10, name)
                    sstore(0x20, symbol)
                    sstore(0x30, decimals)
                    sstore(0x40, totalSupply)
                }
            }

            //Check balance 
            function balanceOf(owner) -> result {
                require(not(eq(owner, sload(1))))
                result := selector("balance", owner)
            }

            function transfer(to, amount){
                require(or(eq(amount, selector("balance", caller())), lt(amount, selector("balance", caller()))))
                update(caller(), to, amount)
            }

            function transferFrom(from, to, amount){
                require(or(eq(amount, selector("balance", from)), lt(amount, selector("balance", from))))
                update(from, to, amount)
            }
            
            function update(from, to, amount){
                let totalSupply := sload(selector("totalSupply", 0))
                switch eq(from, sload(1)) 
                    case 0 {sstore(selectSlot("totalSupply", 0), add(totalSupply, amount))}
                    case 1 {sstore(selectSlot("totalSupply", 0), sub(totalSupply, amount))}
                
                switch eq(to, sload(1))
                    case 0 {sstore(selectSlot("totalSupply", 0), sub(totalSupply, amount))}
                    case 1 {sstore(selectSlot("totalSupply", 0), add(totalSupply, amount))}

                emitEvent(from, to, amount)   
            }

            function require(condition){
                if iszero(condition) {revert(0,0)}
            }

            function mint(account, amount){
                require(not(eq(account, calldataload(1))))
                update(calldataload(1), account, amount)
            }

            function burn(account, amount){
                require(not(eq(account, calldataload(1))))
                update(account, calldataload(1), amount)
            }
        }
    }
}
