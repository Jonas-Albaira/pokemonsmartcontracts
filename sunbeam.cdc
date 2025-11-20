import NonFungibleToken from 0xNONFUNGIBLETOKEN
import MetadataViews from 0xMETADATAVIEWS

// 🌞 Sunbeam Collectibles: Cute, personality-driven NFTs for Flow
pub contract SunbeamCollectibles: NonFungibleToken {

    // 🌟 NFT metadata: personality, mood, moves, stats
    pub struct SunbeamData {
        pub let name: String
        pub var personality: String   // e.g., "Energetic 💛"
        pub var mood: String          // e.g., "Sleepy 💤"
        pub var baseHp: UInt16
        pub var baseAttack: UInt16
        pub var baseDefense: UInt16
        pub var moves: [String]       // e.g., ["Sparkle Beam ✨", "Sunny Hug 🌞"]

        init(
            name: String,
            personality: String,
            mood: String,
            baseHp: UInt16,
            baseAttack: UInt16,
            baseDefense: UInt16,
            moves: [String]
        ) {
            self.name = name
            self.personality = personality
            self.mood = mood
            self.baseHp = baseHp
            self.baseAttack = baseAttack
            self.baseDefense = baseDefense
            self.moves = moves
        }
    }

    // 💎 NFT resource with level-up and move customization
    pub resource SunbeamNFT: NonFungibleToken.INFT, MetadataViews.Resolver {
        pub let id: UInt64
        pub var data: SunbeamData
        pub var level: UInt8
        pub var currentHp: UInt16

        init(id: UInt64, data: SunbeamData) {
            self.id = id
            self.data = data
            self.level = 1
            self.currentHp = data.baseHp
        }

        pub fun levelUp() {
            self.level = self.level + 1
            self.currentHp = self.currentHp + UInt16(5)
            emit SunbeamLeveledUp(id: self.id, name: self.data.name, newLevel: self.level)
        }

        // ✨ Front-end friendly customization
        pub fun updatePersonality(newPersonality: String) { self.data.personality = newPersonality }
        pub fun updateMood(newMood: String) { self.data.mood = newMood }
        pub fun addMove(newMove: String) { self.data.moves.append(newMove) }
        pub fun replaceMove(index: Int, newMove: String) { self.data.moves[index] = newMove }

        // 🎨 Metadata for IG-ready display
        pub fun resolveView(_ viewType: Type): AnyStruct? {
            switch viewType {
            case Type<MetadataViews.Display>():
                return MetadataViews.Display(
                    name: self.data.name,
                    description: "Level \(self.level) 🌞 Personality: \(self.data.personality), Mood: \(self.data.mood), Moves: \(self.data.moves.joined(separator: ", "))",
                    thumbnail: MetadataViews.HTTPFile(url: "https://ipfs.io/ipfs/<hash>/\(self.data.name).png")
                )
            default:
                return nil
            }
        }
    }

    // 🏛 Collection resource for each user
    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
        pub var owned: @{UInt64: SunbeamNFT}

        init() { self.owned <- {} }

        pub fun deposit(token: @NonFungibleToken.NFT) { let nft <- token as! @SunbeamNFT; self.owned[nft.id] <-! nft }
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT { let nft <- self.owned.remove(key: withdrawID) ?? panic("NFT not found"); return <- nft }
        pub fun getIDs(): [UInt64] { return self.owned.keys }
        pub fun borrowNFT(id: UInt64): &SunbeamNFT { return &self.owned[id] as &SunbeamNFT ?? panic("NFT not found") }
    }

    // 🛠 Admin resource for minting new NFTs
    pub resource Admin {
        pub fun mintNFT(
            recipient: &Collection,
            name: String,
            personality: String,
            mood: String,
            baseHp: UInt16,
            baseAttack: UInt16,
            baseDefense: UInt16,
            moves: [String]
        ) {
            let newID = SunbeamCollectibles.totalSupply + UInt64(1)
            let data = SunbeamData(name: name, personality: personality, mood: mood, baseHp: baseHp, baseAttack: baseAttack, baseDefense: baseDefense, moves: moves)
            let newNFT <- create SunbeamNFT(id: newID, data: data)
            recipient.deposit(token: <- newNFT)
            SunbeamCollectibles.totalSupply = newID
            emit SunbeamMinted(id: newID, name: name)
        }
    }

    pub var totalSupply: UInt64

    pub event SunbeamM
