# creditum-cordapp
An endeavour to build cordaapp with maven, java and docker-compose

### Test locally
* Move to development directory
```
cd /path/to/code
```
* Build jar using maven
```
mvn clean install
```
* Run the local network
```
sh ./create_nodes.sh
```
* Login to your nodes, password is `test`, check `*.conf` file to figure out port
```
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p 2000 user1@localhost
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p 2001 user1@localhost
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p 2002 user1@localhost
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p 2003 user1@localhost
```

#### Login to the Bank node
```
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p 2001 user1@localhost
```
* Check available commands
```
help
```
* To list available flows
```
flow list
```
* To start a flow
```
flow start IOUIssueFlow$InitiatorFlow state: {amount: $1000, lender: "O=Bank,OU=coffeebeans,L=Sydney,C=AU", borrower: "O=Hedge Fund,OU=coffeebeans,L=Sydney,C=AU"}
```
Response
```
 ✓ Starting
          Requesting signature by notary service
              Requesting signature by Notary service
              Validating response from Notary service
     ✓ Broadcasting transaction to participants
▶︎ Done
Flow completed with result: SignedTransaction(id=2F463DE867BAF01DAE827D83E9712AF9C6526F206AA0282ABC30317405143DDB)
```
* Query the bank valet
```
run vaultQuery contractStateType: com.coffeebeans.creditum.state.IOUState
```

Response
```
states:
- state:
    data: !<com.coffeebeans.creditum.state.IOUState>
      amount: "1000.00 USD"
      lender: "OU=coffeebeans, O=Bank, L=Sydney, C=AU"
      borrower: "OU=coffeebeans, O=Hedge Fund, L=Sydney, C=AU"
      paid: "0.00 USD"
      linearId:
        externalId: null
        id: "2fbe4810-76cc-4426-9e97-62ab07346883"
    contract: "com.coffeebeans.creditum.contract.IOUContract"
    notary: "OU=coffeebeans, O=Notary Service, L=Sydney, C=AU"
    encumbrance: null
    constraint: !<net.corda.core.contracts.HashAttachmentConstraint>
      attachmentId: "0FC65B88209E63154CD70F1A34CAF85993FA5B23A19BFD6364D03115FF5BA5C6"
  ref:
    txhash: "2F463DE867BAF01DAE827D83E9712AF9C6526F206AA0282ABC30317405143DDB"
    index: 0
statesMetadata:
- ref:
    txhash: "2F463DE867BAF01DAE827D83E9712AF9C6526F206AA0282ABC30317405143DDB"
    index: 0
  contractStateClassName: "com.coffeebeans.creditum.state.IOUState"
  recordedTime: "2020-07-05T15:26:05.971Z"
  consumedTime: null
  status: "UNCONSUMED"
  notary: "OU=coffeebeans, O=Notary Service, L=Sydney, C=AU"
  lockId: null
  lockUpdateTime: null
  relevancyStatus: "RELEVANT"
  constraintInfo:
    constraint:
      attachmentId: "0FC65B88209E63154CD70F1A34CAF85993FA5B23A19BFD6364D03115FF5BA5C6"
totalStatesAvailable: -1
stateTypes: "UNCONSUMED"
otherResults: []
```

#### Login to the Hedge Fund node
```
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p 2003 user1@localhost
```
* Query the hedge fund valet
```
run vaultQuery contractStateType: com.coffeebeans.creditum.state.IOUState
```
Response (state will also be found in this vault as Hedge Fund node was participant in the flow started above)
```
states:
- state:
    data: !<com.coffeebeans.creditum.state.IOUState>
      amount: "1000.00 USD"
      lender: "OU=coffeebeans, O=Bank, L=Sydney, C=AU"
      borrower: "OU=coffeebeans, O=Hedge Fund, L=Sydney, C=AU"
      paid: "0.00 USD"
      linearId:
        externalId: null
        id: "2fbe4810-76cc-4426-9e97-62ab07346883"
    contract: "com.coffeebeans.creditum.contract.IOUContract"
    notary: "OU=coffeebeans, O=Notary Service, L=Sydney, C=AU"
    encumbrance: null
    constraint: !<net.corda.core.contracts.HashAttachmentConstraint>
      attachmentId: "0FC65B88209E63154CD70F1A34CAF85993FA5B23A19BFD6364D03115FF5BA5C6"
  ref:
    txhash: "2F463DE867BAF01DAE827D83E9712AF9C6526F206AA0282ABC30317405143DDB"
    index: 0
statesMetadata:
- ref:
    txhash: "2F463DE867BAF01DAE827D83E9712AF9C6526F206AA0282ABC30317405143DDB"
    index: 0
  contractStateClassName: "com.coffeebeans.creditum.state.IOUState"
  recordedTime: "2020-07-05T15:26:06.217Z"
  consumedTime: null
  status: "UNCONSUMED"
  notary: "OU=coffeebeans, O=Notary Service, L=Sydney, C=AU"
  lockId: null
  lockUpdateTime: null
  relevancyStatus: "RELEVANT"
  constraintInfo:
    constraint:
      attachmentId: "0FC65B88209E63154CD70F1A34CAF85993FA5B23A19BFD6364D03115FF5BA5C6"
totalStatesAvailable: -1
stateTypes: "UNCONSUMED"
otherResults: []
```
#### Login to the Corporation node
```
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p 2002 user1@localhost
```
* Query the corporation valet
```
run vaultQuery contractStateType: com.coffeebeans.creditum.state.IOUState
```
Response (state will not be in this vault as Corporation node was not participant in the flow started above)
```
states: []
statesMetadata: []
totalStatesAvailable: -1
stateTypes: "UNCONSUMED"
otherResults: []
```