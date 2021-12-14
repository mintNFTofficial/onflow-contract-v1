pub contract MINTNFTINCNonFungibleToken {
  pub var totalSupply: UInt64
  pub event ContractInitialized()
  pub event Withdraw(id: UInt64, from: Address?)
  pub event Deposit(id: UInt64, to: Address?)

   pub resource interface INFT {
        pub let id: UInt64
    }

  pub resource NFT: INFT {
    pub let id: UInt64
    pub let name: String 
    pub let symbol: String
    pub let description: String
    pub let collectionName: String
    pub let tokenURI: String
    pub let mintNFTId: String
    pub let mintNFTStandard: String
    pub let mintNFTVideoURI: String
    pub let mattelId: String
    pub let terms: String
    pub let burnable: Bool


    init(_name: String, _symbol: String, _description: String, _collectionName: String, _tokenURI: String, _mintNFTId: String,_mintNFTStandard: String, _mintNFTVideoURI: String, _mattelId: String , _terms: String) {
      self.id = MINTNFTINCNonFungibleToken.totalSupply
      MINTNFTINCNonFungibleToken.totalSupply = MINTNFTINCNonFungibleToken.totalSupply + 1

      self.name = _name
      self.symbol = _symbol
      self.description = _description
      self.collectionName = _collectionName
      self.tokenURI = _tokenURI
      self.mintNFTId = _mintNFTId
      self.mintNFTStandard = _mintNFTStandard
      self.mintNFTVideoURI = _mintNFTVideoURI
      self.mattelId = _mattelId
      self.terms = _terms
      self.burnable = false;

      
    }
  }

  pub resource interface CollectionPublic {
    pub fun deposit(token: @NFT)
    pub fun getIDs(): [UInt64]
    pub fun borrowNFT(id: UInt64): &NFT
  }

    pub resource interface Provider {
        pub fun withdraw(withdrawID: UInt64): @NFT {
            post {
                result.id == withdrawID: "The ID of the withdrawn token must be the same as the requested ID"
            }
        }
    }
    pub resource interface Receiver {
        pub fun deposit(token: @NFT)
    }


  pub resource Collection: Receiver, Provider, CollectionPublic {
    pub var ownedNFTs: @{UInt64: NFT}

    pub fun deposit(token: @NFT) {
      let dToken <- token
      emit Deposit(id: dToken.id, to: self.owner?.address)
      self.ownedNFTs[dToken.id] <-! dToken
    }

    pub fun withdraw(withdrawID: UInt64): @NFT {
      let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("This NFT does not exist")
      emit Withdraw(id: token.id, from: self.owner?.address)
      return <- token
    }

    pub fun getIDs(): [UInt64] {
      return self.ownedNFTs.keys
    }

    pub fun borrowNFT(id: UInt64): &NFT {
      return &self.ownedNFTs[id] as &NFT
    }

    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  pub fun createEmptyCollection(): @Collection {
    return <- create Collection()
  }

  pub fun createToken(name: String, symbol: String, description: String, collectionName: String, tokenURI: String, mintNFTId: String, mintNFTStandard: String, mintNFTVideoURI: String, mattelId: String , terms: String): @NFT {
    return <- create NFT(_name: name, _symbol: symbol, _description: description, _collectionName: collectionName, _tokenURI: tokenURI, _mintNFTId: mintNFTId, _mintNFTStandard: mintNFTStandard, _mintNFTVideoURI: mintNFTVideoURI, _mattelId: mattelId, _terms: terms)
  }

  init() {
    self.totalSupply = 0
  }
}