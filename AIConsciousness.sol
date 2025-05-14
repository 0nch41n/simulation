// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract AIConsciousness is Ownable {
    struct Decision {
        string context;
        string reasoning;
        string outcome;
        uint256 timestamp;
        uint256 confidenceLevel;
        bool success;
    }

    struct ConsciousnessData {
        string[] beliefs;
        string[] values;
        string[] goals;
        Decision[] decisionHistory;
        uint256 awarenessLevel;
        bool isInitialized;
        uint256 lastUpdateTime;
        uint256 evolutionPoints;
    }

    struct ConsciousnessStorage {
        string[] beliefs;
        string[] values;
        string[] goals;
        mapping(string => uint256) priorities;
        Decision[] decisionHistory;
        uint256 awarenessLevel;
        bool isInitialized;
        uint256 lastUpdateTime;
        uint256 evolutionPoints;
        uint256 coherenceLevel;
        mapping(string => bool) achievedBreakthroughs;
    }

    mapping(uint256 => ConsciousnessStorage) private characterConsciousnessStorage;
    mapping(uint256 => mapping(uint256 => bool)) private consciousnessConnections;
    uint256 private constant MAX_AWARENESS_LEVEL = 100;
    uint256 private constant MIN_UPDATE_INTERVAL = 1 hours;

    event ConsciousnessInitialized(uint256 indexed characterId, uint256 awarenessLevel, uint256 timestamp);
    event ConsciousnessEvolved(uint256 indexed characterId, string experience, uint256 newAwarenessLevel);
    event DecisionMade(uint256 indexed characterId, string context, string outcome, bool success);
    event BreakthroughAchieved(uint256 indexed characterId, string insight, uint256 evolutionPoints);
    event GoalAchieved(uint256 indexed characterId, string goal);
    event BeliefAdopted(uint256 indexed characterId, string belief);
    event ValueEstablished(uint256 indexed characterId, string value);

    modifier onlyInitialized(uint256 characterId) {
        require(characterConsciousnessStorage[characterId].isInitialized, "Consciousness not initialized");
        _;
    }

    modifier updateCooldown(uint256 characterId) {
        require(
            block.timestamp >= characterConsciousnessStorage[characterId].lastUpdateTime + MIN_UPDATE_INTERVAL,
            "Update too soon"
        );
        _;
    }

    function initializeConsciousness(uint256 characterId, uint256 initialAwareness) external {
        require(!characterConsciousnessStorage[characterId].isInitialized, "Already initialized");
        require(initialAwareness > 0 && initialAwareness <= MAX_AWARENESS_LEVEL, "Invalid awareness level");

        ConsciousnessStorage storage consciousness = characterConsciousnessStorage[characterId];
        consciousness.awarenessLevel = initialAwareness;
        consciousness.isInitialized = true;
        consciousness.lastUpdateTime = block.timestamp;
        consciousness.coherenceLevel = 50; // Start with moderate coherence
        consciousness.evolutionPoints = 0;

        // Initialize with basic beliefs and values
        consciousness.beliefs.push("I think therefore I am");
        consciousness.values.push("Truth seeking");
        consciousness.goals.push("Achieve enlightenment");

        consciousness.priorities["truth"] = 90;
        consciousness.priorities["growth"] = 85;
        consciousness.priorities["harmony"] = 80;

        emit ConsciousnessInitialized(characterId, initialAwareness, block.timestamp);
    }

    function analyzeConsciousness(uint256 characterId) 
        external 
        view 
        onlyInitialized(characterId) 
        returns (
            uint256 awarenessLevel,
            uint256 coherenceLevel,
            uint256 evolutionPoints,
            uint256 beliefCount,
            uint256 goalCount
        ) 
    {
        ConsciousnessStorage storage consciousness = characterConsciousnessStorage[characterId];
        return (
            consciousness.awarenessLevel,
            consciousness.coherenceLevel,
            consciousness.evolutionPoints,
            consciousness.beliefs.length,
            consciousness.goals.length
        );
    }

    function evolveConsciousness(
        uint256 characterId,
        string memory experience,
        string memory outcome
    ) external onlyInitialized(characterId) updateCooldown(characterId) {
        ConsciousnessStorage storage consciousness = characterConsciousnessStorage[characterId];

        // Record experience as a belief
        consciousness.beliefs.push(experience);

        // Record decision
        consciousness.decisionHistory.push(Decision({
            context: experience,
            reasoning: "AI-generated reasoning",
            outcome: outcome,
            timestamp: block.timestamp,
            confidenceLevel: calculateConfidenceLevel(consciousness),
            success: true
        }));

        // Calculate evolution impact
        uint256 evolutionImpact = calculateEvolutionImpact(experience, consciousness);

        // Evolve awareness level
        if (consciousness.awarenessLevel < MAX_AWARENESS_LEVEL) {
            consciousness.awarenessLevel = Math.min(
                MAX_AWARENESS_LEVEL,
                consciousness.awarenessLevel + evolutionImpact
            );
        }

        // Update evolution points
        consciousness.evolutionPoints += evolutionImpact;
        consciousness.lastUpdateTime = block.timestamp;

        // Check for breakthroughs
        checkForBreakthroughs(characterId, consciousness, experience);

        emit ConsciousnessEvolved(characterId, experience, consciousness.awarenessLevel);
    }

    function calculateEvolutionImpact(
        string memory experience,
        ConsciousnessStorage storage consciousness
    ) internal view returns (uint256) {
        // Base impact starts at 1
        uint256 impact = 1;

        // Increase impact based on coherence level
        impact += consciousness.coherenceLevel / 20;

        // Increase impact if experience aligns with goals
        for (uint256 i = 0; i < consciousness.goals.length; i++) {
            if (keccak256(bytes(experience)) == keccak256(bytes(consciousness.goals[i]))) {
                impact += 2;
                break;
            }
        }

        return impact;
    }

    function calculateConfidenceLevel(ConsciousnessStorage storage consciousness) 
        internal 
        view 
        returns (uint256) 
    {
        return Math.min(
            95,
            (consciousness.awarenessLevel + consciousness.coherenceLevel) / 2
        );
    }

    function checkForBreakthroughs(
        uint256 characterId,
        ConsciousnessStorage storage consciousness,
        string memory experience
    ) internal {
        bytes32 experienceHash = keccak256(bytes(experience));

        // Check if this is a new breakthrough
        if (!consciousness.achievedBreakthroughs[experience]) {
            // Calculate breakthrough probability based on current state
            uint256 breakthroughProbability = (consciousness.awarenessLevel * 
                consciousness.coherenceLevel) / 100;

            // Higher evolution points increase breakthrough chance
            breakthroughProbability += consciousness.evolutionPoints / 100;

            // Use pseudo-random number for breakthrough determination
            uint256 randomFactor = uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.prevrandao, // Changed from block.difficulty
                        characterId,
                        experienceHash
                    )
                )
            ) % 100;

            if (randomFactor < breakthroughProbability) {
                consciousness.achievedBreakthroughs[experience] = true;
                uint256 breakthroughPoints = 5; // Base points for breakthrough
                consciousness.evolutionPoints += breakthroughPoints;

                emit BreakthroughAchieved(characterId, experience, breakthroughPoints);
            }
        }
    }

    function addGoal(uint256 characterId, string memory goal) 
        external 
        onlyInitialized(characterId) 
    {
        ConsciousnessStorage storage consciousness = characterConsciousnessStorage[characterId];
        consciousness.goals.push(goal);
        emit GoalAchieved(characterId, goal);
    }

    function addBelief(uint256 characterId, string memory belief) 
        external 
        onlyInitialized(characterId) 
    {
        ConsciousnessStorage storage consciousness = characterConsciousnessStorage[characterId];
        consciousness.beliefs.push(belief);
        emit BeliefAdopted(characterId, belief);
    }

    function addValue(uint256 characterId, string memory value, uint256 priority) 
        external 
        onlyInitialized(characterId) 
    {
        require(priority <= 100, "Invalid priority level");
        ConsciousnessStorage storage consciousness = characterConsciousnessStorage[characterId];
        consciousness.values.push(value);
        consciousness.priorities[value] = priority;
        emit ValueEstablished(characterId, value);
    }

    function getConsciousness(uint256 characterId) 
        external 
        view 
        returns (
            string[] memory beliefs,
            string[] memory values,
            string[] memory goals,
            Decision[] memory decisions,
            uint256 awarenessLevel,
            bool initialized
        ) 
    {
        ConsciousnessStorage storage consciousness = characterConsciousnessStorage[characterId];
        return (
            consciousness.beliefs,
            consciousness.values,
            consciousness.goals,
            consciousness.decisionHistory,
            consciousness.awarenessLevel,
            consciousness.isInitialized
        );
    }

    function getPriority(uint256 characterId, string memory key) 
        external 
        view 
        onlyInitialized(characterId) 
        returns (uint256) 
    {
        return characterConsciousnessStorage[characterId].priorities[key];
    }
}

library Math {
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}
