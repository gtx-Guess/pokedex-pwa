<template>
    <!-- Splash Screen -->
    <div v-if="showSplashScreen" class="splash-screen">
        <div class="splash-content">
            <h1 class="splash-title">PWA-Pokedex</h1>
            <div class="splash-pokeball-container">
                <img class="splash-pokeball" :class="{ spinning: isStarting }" src="/pokeball.svg" alt="Pokeball" @click="startApp">
            </div>
            <p class="splash-instruction">Click the pokeball to start!</p>
        </div>
    </div>

    <header v-show="!showSplashScreen">
        <h1>PWA-Pokedex</h1>
        <button class="drop" id="pokemon-filter" @click="toggleFilterModal">
            <svg xmlns="http://www.w3.org/2000/svg" height="1em" viewBox="0 0 448 512"><!--! Font Awesome Free 6.4.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2023 Fonticons, Inc. --><path d="M0 96C0 78.3 14.3 64 32 64H416c17.7 0 32 14.3 32 32s-14.3 32-32 32H32C14.3 128 0 113.7 0 96zM0 256c0-17.7 14.3-32 32-32H416c17.7 0 32 14.3 32 32s-14.3 32-32 32H32c-17.7 0-32-14.3-32-32zM448 416c0 17.7-14.3 32-32 32H32c-17.7 0-32-14.3-32-32s14.3-32 32-32H416c17.7 0 32 14.3 32 32z"/></svg>
        </button>
    </header>
    <main v-show="!showSplashScreen">
        <div class="search-box">
            <input type="search" name="Search" placeholder="     Type a pokemon's name and press Enter" v-model="searchQuery" @keyup.enter="handleSearch">
            <button class="search-btn" @click="handleSearch" :disabled="!searchQuery.trim()">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><!--! Font Awesome Free 6.4.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2023 Fonticons, Inc. --><path d="M416 208c0 45.9-14.9 88.3-40 122.7L502.6 457.4c12.5 12.5 12.5 32.8 0 45.3s-32.8 12.5-45.3 0L330.7 376c-34.4 25.2-76.8 40-122.7 40C93.1 416 0 322.9 0 208S93.1 0 208 0S416 93.1 416 208zM208 352a144 144 0 1 0 0-288 144 144 0 1 0 0 288z"/></svg>
            </button>
            <button class="clear-btn" @click="clearSearch" v-if="searchQuery">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512"><!--! Font Awesome Free 6.4.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2023 Fonticons, Inc. --><path d="M342.6 150.6c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0L192 210.7 86.6 105.4c-12.5-12.5-32.8-12.5-45.3 0s-12.5 32.8 0 45.3L146.7 256 41.4 361.4c-12.5 12.5-12.5 32.8 0 45.3s32.8 12.5 45.3 0L192 301.3 297.4 406.6c12.5 12.5 32.8 12.5 45.3 0s12.5-32.8 0-45.3L237.3 256 342.6 150.6z"/></svg>
            </button>
        </div><br>
        <div v-if="isLoading" class="loading-spinner">
            <img class="pokeball" src="/pokeball.svg" alt="Svg Image">
            <p>Loading...</p>
        </div>
        <div v-else>
            <div v-if="showFilteredList" class="pokemon-list">
                <form class="pokemon" :class="{ 'searched-pokemon': pm.isSearched }" v-for="pm in filteredPokemonList" :key="`poke` + pm.id" @click=pokemonCardClicked(pm)>
                    <img :src=pm.img alt="pokemon image" loading="lazy">
                    <p>{{ formatText(pm.name) }}</p>
                    <span v-if="pm.isSearched" class="search-indicator">Searched</span>
                </form>
            </div>
            <div v-else-if="showList" class="pokemon-list">
                <form class="pokemon" v-for="pm in pokemonList" :key="`poke` + pm.id" @click=pokemonCardClicked(pm)>
                    <img :src=pm.img alt="pokemon image" loading="lazy">
                    <p>{{ formatText(pm.name) }}</p>
                </form>
            </div>
            <div v-if="showFilteredList && filteredPokemonList.length === 0" class="no-results">
                <p v-if="searchQuery">Pokemon "{{ formatText(searchQuery) }}" not found</p>
                <p v-else-if="selectedType">No Pokemon found for {{ formatText(selectedType) }} type</p>
                <p v-if="searchQuery" class="search-hint">Try searching for: "pikachu", "charizard", "mew", etc.</p>
            </div>
            
            <!-- Evolution Search Results Indicator -->
            <div v-if="searchQuery && showFilteredList && filteredPokemonList.length > 0" class="evolution-info">
                <p>Showing {{ formatText(searchQuery) }} and its evolution family ({{ filteredPokemonList.length }} Pokemon)</p>
            </div>
            
            <!-- Active Filter Indicator -->
            <div v-if="selectedType && showFilteredList" class="active-filter">
                <span>Showing {{ formatText(selectedType) }} type Pokemon ({{ Math.floor(typePageOffset / typePageLimit) + 1 }} of {{ Math.ceil(currentTypeData?.pokemon?.length / typePageLimit) || 1 }})</span>
                <button @click="clearTypeFilter" class="clear-active-filter">Clear Filter</button>
            </div>
        </div>
        <div v-if="pokeCardLoading" class="poke-card-loading">
                <img class="pokeball-img" src="/pokeball.svg" alt="Svg Image">
            </div>
        <div v-else>
            <div v-if="currentPokemon" class="poke-card-outer" @click="closePokemonCard">
                <div class="pokemon-card" @click.stop>
                    <button class="exit-pk" @click="closePokemonCard">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512"><path d="M342.6 150.6c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0L192 210.7 86.6 105.4c-12.5-12.5-32.8-12.5-45.3 0s-12.5 32.8 0 45.3L146.7 256 41.4 361.4c-12.5 12.5-12.5 32.8 0 45.3s32.8 12.5 45.3 0L192 301.3 297.4 406.6c12.5 12.5 32.8 12.5 45.3 0s12.5-32.8 0-45.3L237.3 256 342.6 150.6z"/></svg>
                    </button>
                    <div class="pokemon-top-card" :style="{backgroundColor: pokeCardBG}">
                        <div class="pk-card-header">
                            <h1 class="pk-header-name"> {{ currentPokemon.name }} </h1>
                            <div class="pk-header-stats-right">
                                <span>HP</span>
                                <span>{{ currentPokemon.hp }}</span>
                                <img :src="'/icons/' + currentPokemon.type + '_type.png'" alt="type" loading="lazy">
                            </div>
                        </div>
                        <span class="pk-bg-img-span"><img class="pk-img" :src=currentPokemon.img alt="pokemon image" loading="lazy"></span>
                        <div class="pk-stats">
                            <p>Height: {{ currentPokemon.ht }} ft</p>
                            <p>Weight: {{ currentPokemon.wt }} lb</p>
                        </div>
                        <div class="pk-card-stats">
                            <p class="pk-moves"><span>{{ currentPokemon.m1.name }}</span> <span>{{ currentPokemon.m1.power }}</span></p>
                            <p class="pk-moves"><span>{{ currentPokemon.m2.name }}</span> <span>{{ currentPokemon.m2.power }}</span></p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <span class="page-buttons">
            <button v-if=" previousPage !== null " @click="getPokemonPage('Previous')">Previous Page</button>
            <button v-if=" nextPage !== null " @click="getPokemonPage('Next')">Next Page</button>
        </span>

        <!-- Type Filter Modal -->
        <div v-if="showFilterModal" class="filter-modal-overlay" @click="closeFilterModal">
            <div class="filter-modal" @click.stop>
                <div class="filter-modal-header">
                    <h2>Filter by Type</h2>
                    <button class="close-modal" @click="closeFilterModal">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512"><path d="M342.6 150.6c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0L192 210.7 86.6 105.4c-12.5-12.5-32.8-12.5-45.3 0s-12.5 32.8 0 45.3L146.7 256 41.4 361.4c-12.5 12.5-12.5 32.8 0 45.3s32.8 12.5 45.3 0L192 301.3 297.4 406.6c12.5 12.5 32.8 12.5 45.3 0s12.5-32.8 0-45.3L237.3 256 342.6 150.6z"/></svg>
                    </button>
                </div>
                <div class="filter-modal-content">
                    <div class="type-grid">
                        <button 
                            v-for="type in pokemonTypes" 
                            :key="type.name"
                            class="type-button"
                            :class="type.name"
                            @click="filterByType(type.name)"
                        >
                            <img :src="`/icons/${type.name}_type.png`" :alt="type.name + ' type'" loading="lazy">
                            <span>{{ formatText(type.name) }}</span>
                        </button>
                    </div>
                    <div class="filter-actions">
                        <button class="clear-filter-btn" @click="clearTypeFilter">Show All Pokemon</button>
                    </div>
                </div>
            </div>
        </div>
    </main>
</template>

<script setup>
import { ref } from 'vue';

const P = new Pokedex.Pokedex();
const isLoading = ref(false);
const pokeCardLoading = ref(false);
const showList = ref(true);
const showFilteredList = ref(false);
const showFilterModal = ref(false);
const showSplashScreen = ref(true);
const isStarting = ref(false);
const pokemonList = ref([]);
const filteredPokemonList = ref([]);
const searchQuery = ref('');
const selectedType = ref('');
const currentTypeData = ref(null);
const typePageOffset = ref(0);
const typePageLimit = ref(20);
const nextPage = ref(null);
const previousPage = ref(null);
const currentPokemon = ref(null);
const pokeCardBG = ref('grey');

// Pokemon types data
const pokemonTypes = ref([
    { name: 'normal' },
    { name: 'fire' },
    { name: 'water' },
    { name: 'electric' },
    { name: 'grass' },
    { name: 'ice' },
    { name: 'fighting' },
    { name: 'poison' },
    { name: 'ground' },
    { name: 'flying' },
    { name: 'psychic' },
    { name: 'bug' },
    { name: 'rock' },
    { name: 'ghost' },
    { name: 'dragon' },
    { name: 'dark' },
    { name: 'steel' },
    { name: 'fairy' }
]);
const imageUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/';

// Initialize Pokemon data when app starts
const initializePokemonData = async () => {
    isLoading.value = true;
    showList.value = false;
    const resp = await P.getPokemonsList( {limit: 16} );
    nextPage.value = resp.next;
    resp.results.forEach(p => {
        p.id = p.url.split('/').filter( (part) => { return !!part }).pop();
        p.img = imageUrl + p.id + '.png';
    });
    pokemonList.value = resp.results;
    await preLoadImages(pokemonList.value);
    isLoading.value = false;
    showList.value = true;
};

const getPokemonPage = async (pageType) => {
    // Handle type filtering pagination
    if (selectedType.value && currentTypeData.value) {
        pokeCardLoading.value = false;
        isLoading.value = true;
        currentPokemon.value = null;
        
        // Update offset based on page direction
        if (pageType === 'Next') {
            typePageOffset.value += typePageLimit.value;
        } else if (pageType === 'Previous') {
            typePageOffset.value = Math.max(0, typePageOffset.value - typePageLimit.value);
        }
        
        await loadTypeFilteredPage();
        return;
    }
    
    // Original pagination logic for normal list
    const page = pageType === 'Next' ? nextPage.value : previousPage.value;
    if (!page) { return; }
    
    pokeCardLoading.value = false;
    isLoading.value = true;
    showList.value = false;
    currentPokemon.value = null;
    
    let resp = await P.resource([page]);
    resp = resp[0];
    resp.results.forEach(p => {
        p.id = p.url.split('/').filter((part) => { return !!part }).pop();
        p.img = imageUrl + p.id + '.png';
    });
    pokemonList.value = resp.results;
    nextPage.value = resp.next;
    previousPage.value = resp.previous;
    await preLoadImages(pokemonList.value);
    isLoading.value = false;
    showList.value = true;
};

const preLoadImages = async (pokemonList) => {
    const imagePromises = pokemonList.map((pm) => {
        return new Promise((resolve, reject) => {
            const image = new Image();
            image.src = pm.img;
            image.onload = resolve;
            image.onerror = reject;
        }); 
    });

    await Promise.all(imagePromises);
};

const pokemonCardClicked = async (pokemon) => {
    if(!pokemon.clicked){
        pokeCardLoading.value = true;
        const resp = await P.getPokemonByName(pokemon.name);
        pokemon.clicked = false;
        pokemon.name = formatText(pokemon.name);
        pokemon.hp = resp.stats[0].base_stat;
        pokemon.wt = resp.weight;
        pokemon.ht = resp.height;
        pokemon.type = resp.types[0].type.name;
        pokemon.m1 = { 
            name: formatText(resp.moves[0].move.name), 
            power: Math.floor((Math.floor(Math.random() * (80 - 10 + 1 )) + 10)/10) * 10
        };
        pokemon.m2 = {
            name: formatText(resp.moves[1].move.name),
            power: Math.floor((Math.floor(Math.random() * (200 - 50 + 1 )) + 50)/10) * 10
        };
        chosePkCardBGColor(pokemon.type);
        currentPokemon.value = pokemon;
        pokeCardLoading.value = false;
        pokemon.clicked = true;
    }else{
        currentPokemon.value = pokemon;
    }

    // console.log(resp);
    // console.log(currentPokemon);
};

const closePokemonCard = () => {
    currentPokemon.value = null;
};

const chosePkCardBGColor = (type) => {
    switch(type){
        case 'fire':
            pokeCardBG.value = 'rgb(255, 155, 144)';
            break;
        case 'water':
        case 'ice':
            pokeCardBG.value = '#5e5eff';
            break;
        case 'grass':
        case 'bug': 
            pokeCardBG.value = '#a9e947';
            break;
        case 'poison':
        case 'ghost':
        case 'psychic':
            pokeCardBG.value = 'rgb(182 97 249)';
            break;
        case 'dark':
            pokeCardBG.value = 'rgb(71 70 73)';
            break;
        case 'normal':
        case 'steel':
            pokeCardBG.value = 'rgb(203 203 203)';
            break;
        case 'flying':
        case 'dragon':
            pokeCardBG.value = 'rgb(175 175 242)';
            break;
        case 'fairy':
            pokeCardBG.value = 'rgb(250 93 204)';
            break;
        case 'electric':
            pokeCardBG.value = '#efef8f';
            break;
        case 'fighting': 
            pokeCardBG.value = '#a73333';
            break;
        case 'rock':
        case 'ground':
            pokeCardBG.value = '#916262';
            break;
        default:
            pokeCardBG.value = 'white'
            break;
    };
};

const formatText = (text) => {
    if( text.includes('-') ){
            text = text.replace('-', ' ');
    }
    return text.charAt(0).toUpperCase() + text.slice(1);
};

const handleSearch = async () => {
    const query = searchQuery.value.toLowerCase().trim();
    
    if (query === '') {
        showFilteredList.value = false;
        showList.value = true;
        return;
    }
    
    try {
        isLoading.value = true;
        showList.value = false;
        
        // Search for the specific Pokemon by name
        const pokemon = await P.getPokemonByName(query);
        
        // Get the evolution chain
        const evolutionResults = await getEvolutionChain(pokemon);
        
        filteredPokemonList.value = evolutionResults;
        showFilteredList.value = true;
        
    } catch (error) {
        // Pokemon not found
        filteredPokemonList.value = [];
        showFilteredList.value = true;
    } finally {
        isLoading.value = false;
    }
};

const getEvolutionChain = async (pokemon) => {
    try {
        // Get species data to access evolution chain
        const species = await P.getPokemonSpeciesByName(pokemon.name);
        
        // Get evolution chain data
        const evolutionChainResponse = await P.resource([species.evolution_chain.url]);
        const evolutionChain = evolutionChainResponse[0];
        
        // Extract all Pokemon from the evolution chain
        const evolutionPokemon = [];
        
        // Helper function to recursively get all evolutions
        const extractEvolutions = (chainLink) => {
            if (chainLink.species) {
                const id = chainLink.species.url.split('/').filter(part => part).pop();
                evolutionPokemon.push({
                    id: id,
                    name: chainLink.species.name,
                    url: chainLink.species.url,
                    img: imageUrl + id + '.png',
                    isSearched: chainLink.species.name === pokemon.name
                });
            }
            
            // Process evolutions
            if (chainLink.evolves_to && chainLink.evolves_to.length > 0) {
                chainLink.evolves_to.forEach(evolution => {
                    extractEvolutions(evolution);
                });
            }
        };
        
        // Start extraction from the base of the chain
        extractEvolutions(evolutionChain.chain);
        
        // Sort so searched Pokemon appears first, then by ID
        evolutionPokemon.sort((a, b) => {
            if (a.isSearched) return -1;
            if (b.isSearched) return 1;
            return parseInt(a.id) - parseInt(b.id);
        });
        
        // Preload images
        await preLoadImages(evolutionPokemon);
        
        return evolutionPokemon;
        
    } catch (error) {
        console.error('Error fetching evolution chain:', error);
        // Fallback to just the searched Pokemon
        const fallbackResult = {
            id: pokemon.id,
            name: pokemon.name,
            url: `https://pokeapi.co/api/v2/pokemon/${pokemon.id}/`,
            img: imageUrl + pokemon.id + '.png',
            isSearched: true
        };
        await preLoadImages([fallbackResult]);
        return [fallbackResult];
    }
};

const clearSearch = () => {
    searchQuery.value = '';
    showFilteredList.value = false;
    showList.value = true;
    filteredPokemonList.value = [];
};

// Filter Modal Functions
const toggleFilterModal = () => {
    showFilterModal.value = !showFilterModal.value;
};

const closeFilterModal = () => {
    showFilterModal.value = false;
};

const filterByType = async (typeName) => {
    try {
        selectedType.value = typeName;
        typePageOffset.value = 0;
        isLoading.value = true;
        showList.value = false;
        showFilterModal.value = false;
        
        // Get Pokemon of specific type from PokeAPI
        const typeData = await P.getTypeByName(typeName);
        currentTypeData.value = typeData;
        
        // Load first page of type-filtered Pokemon
        await loadTypeFilteredPage();
        
    } catch (error) {
        console.error('Error filtering by type:', error);
        filteredPokemonList.value = [];
        showFilteredList.value = true;
        isLoading.value = false;
    }
};

const loadTypeFilteredPage = async () => {
    try {
        const startIndex = typePageOffset.value;
        const endIndex = startIndex + typePageLimit.value;
        const totalPokemon = currentTypeData.value.pokemon.length;
        
        // Extract Pokemon for current page
        const pagePokemons = currentTypeData.value.pokemon.slice(startIndex, endIndex).map(pokemonEntry => {
            const pokemon = pokemonEntry.pokemon;
            const id = pokemon.url.split('/').filter(part => part).pop();
            return {
                id: id,
                name: pokemon.name,
                url: pokemon.url,
                img: imageUrl + id + '.png'
            };
        });
        
        // Update pagination state
        nextPage.value = endIndex < totalPokemon ? 'next' : null;
        previousPage.value = startIndex > 0 ? 'previous' : null;
        
        // Preload images for the filtered Pokemon
        await preLoadImages(pagePokemons);
        
        filteredPokemonList.value = pagePokemons;
        showFilteredList.value = true;
        
    } catch (error) {
        console.error('Error loading type filtered page:', error);
        filteredPokemonList.value = [];
        showFilteredList.value = true;
    } finally {
        isLoading.value = false;
    }
};

const clearTypeFilter = () => {
    selectedType.value = '';
    currentTypeData.value = null;
    typePageOffset.value = 0;
    showFilteredList.value = false;
    showList.value = true;
    filteredPokemonList.value = [];
    showFilterModal.value = false;
};

// Start the app when pokeball is clicked
const startApp = async () => {
    if (isStarting.value) return; // Prevent multiple clicks
    
    isStarting.value = true;
    
    // Wait for spin animation to complete
    setTimeout(async () => {
        showSplashScreen.value = false;
        await initializePokemonData();
        isStarting.value = false;
    }, 1000); // 1 second for the spin animation
};

</script>


<style lang="scss">

$h-color: #32db8f;
*{
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    font-family: 'Fira Sans', sans-serif;
    overflow-x: hidden;
    // &::selection{
    //     background: transparentize(#42b883, 0.5);
    // }
}

/* Splash Screen Styles */
.splash-screen {
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background: white;
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 9999;
}

.splash-content {
    text-align: center;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 30px;
}

.splash-title {
    font-size: 36pt;
    color: $h-color;
    font-weight: bold;
    margin-bottom: 20px;
}

.splash-pokeball-container {
    position: relative;
    padding: 20px; // Add padding to prevent clipping when scaled
    display: flex;
    justify-content: center;
    align-items: center;
}

.splash-pokeball {
    width: 120px;
    height: 120px;
    cursor: pointer;
    transition: transform 0.3s ease;
    
    &:hover:not(.spinning) {
        transform: scale(1.1);
    }
    
    &:active:not(.spinning) {
        transform: scale(0.95);
    }
    
    &.spinning {
        animation: spinFlip 1s ease-in-out;
        cursor: default;
    }
}

.splash-instruction {
    font-size: 18pt;
    color: #666;
    font-weight: 500;
    margin-top: 10px;
    animation: pulse 2s ease-in-out infinite;
}

@keyframes spinFlip {
    0% {
        transform: rotateY(0deg) rotateZ(0deg);
    }
    25% {
        transform: rotateY(90deg) rotateZ(90deg) scale(1.1);
    }
    50% {
        transform: rotateY(180deg) rotateZ(180deg) scale(1.2);
    }
    75% {
        transform: rotateY(270deg) rotateZ(270deg) scale(1.1);
    }
    100% {
        transform: rotateY(360deg) rotateZ(360deg) scale(1);
    }
}

@keyframes pulse {
    0%, 100% {
        opacity: 0.7;
    }
    50% {
        opacity: 1;
    }
}

/* CSS for mobile  */
header{
    position: relative;
    z-index: 9000;
    display: flex;
    width: 100vw;
    background-color: $h-color;
    padding: 10px 0;
    h1{
        width: 90%;
        text-align: center;
        font-size: 28pt;
        // &::selection{
        //     background: transparentize(#4299b8, 0.5);
        // }
    }
    .drop{
        width: 15%;
        margin-right: 10px;
        display: flex;
        justify-content: center;
        align-items: center;
        background-color: transparent;
        svg{
            font-size: 30pt;
        }
    }
}

main{
    padding-top: 2vh;

    .poke-card-loading{
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;

        .pokeball-img{
            height: 100pt;
            background: white;
            border-radius: 50%;
            border: 4px solid #000;
            position: absolute;
            top: 40%;
            animation: spinZ 1.5s linear infinite;
        }

        @keyframes spinZ {
            0% {
                transform: rotateY(0deg);
            }
            100% {
                transform: rotateY(360deg);
            }
        }
    }

    // .clickable-pokeball{
    //     top: 54%;
    //     position: absolute;
    //     height: 50pt;
    //     animation: wiggle .7s ease infinite;
    // }
    // @keyframes wiggle {
    //     0%, 100% { transform: rotate(0); }
    //     25% { transform: rotate(-10deg); }
    //     75% { transform: rotate(10deg); }
    // }

    .poke-card-outer{
        position: fixed;
        top: 0;
        left: 0;
        z-index: 10;
        color: black;
        width: 100vw;
        height: 100vh;
        background: rgba(0, 0, 0, 0.7);
        display: flex;
        justify-content: center;
        align-items: center;
    }
    .pokemon-card{
        position: relative;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        color: black;
        max-width: 90vw;
        max-height: 90vh;
        margin-top: 10vh;
        
        .exit-pk{
            position: absolute;
            top: 8px;
            right: 8px;
            width: 32px;
            height: 32px;
            background: rgba(0, 0, 0, 0.6);
            backdrop-filter: blur(10px);
            border: 2px solid rgba(255, 255, 255, 0.2);
            border-radius: 8px;
            cursor: pointer;
            z-index: 11;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
            transition: all 0.3s ease;
            
            svg {
                width: 16px;
                height: 16px;
                fill: rgba(255, 255, 255, 0.9);
                transition: fill 0.2s ease;
            }
            
            &:hover {
                background: rgba(0, 0, 0, 0.8);
                border-color: rgba(255, 255, 255, 0.4);
                transform: scale(1.05);
                
                svg {
                    fill: white;
                }
            }
        }

        .pokemon-top-card{
            display: flex;
            flex-direction: column;
            background: white;
            width: 90vw;
            height: 85vh;
            max-height: 600px;
            border: 3vw solid yellow;
            border-radius: 10px;
            align-items: center;
            box-shadow: inset 0 0 40px rgba(255, 255, 255, 0.5);
            .pk-bg-img-span{
                background-image: url('/icons/gal2.png');
                background-size: cover; /* or other values like 'contain' */
                background-position: center center; /* or other positions */
                background-repeat: no-repeat;
                width: 90%; display: flex; 
                justify-content: center; 
                border: 2vw solid yellow; 
                background-color: white;
            }
            .pk-img{
                width: 65%;
            }
            .pk-card-header{
                display: flex;
                justify-content: space-between;
                width: 98%;
                margin: 7px;
                .pk-header-name{
                    font-size: 22pt; 
                    font-weight: normal; 
                    margin: 4px;
                }
                .pk-header-stats-right{
                    width: 35%; 
                    display: flex; 
                    align-items: center; 
                    justify-content: space-around;
                    & span:nth-child(1){
                        font-size: 16pt;
                    }
                    & span:nth-child(2){
                        font-weight: normal; 
                        font-size: 18pt;
                    }
                    & img{
                        height: 30pt; 
                        margin: 0; 
                        padding: 0; 
                        border: yellow 1px solid; 
                        border-radius: 25px;
                    }
                }    
            }
            .pk-stats{
                display: flex; 
                font-size: 10pt;
                justify-content: space-between; 
                width: 45%; 
                min-width: 180px;
                background: yellow;
                box-shadow: inset 0 0 30px rgba(255, 255, 255, 0.5);
            }
            .pk-card-stats{
                margin-top: 30px;
                width: 90%;
                height: 25%;
                display: flex;
                flex-direction: column;
                justify-content: space-evenly;
                font-size: 15pt;

                .pk-moves{
                    display: flex;
                    justify-content: space-between;
                }
            }
        }
    }

    .page-buttons{
        padding: 3vh 0;
        display: flex;
        width: 100vw;
        justify-content: center;

        & > button{
            width: 50%;
            font-size: 15pt;
        }
    }

    .loading-spinner {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        height: 100vh;

        .pokeball {
            height: 70pt;
            background: white;
            border-radius: 50%;
            border: 4px solid #000;
            position: absolute;
            top: 50%;
            animation: spin 1.5s linear infinite;
        }

        @keyframes spin {
            0% {
                transform: rotate(0deg);
            }
            100% {
                transform: rotate(360deg);
            }
        }
    }

    .pokemon-list{
        display: grid;
        gap: 10px;
        grid-template-columns: repeat(4, 1fr);
        width: 96vw;
        margin-left: 8px;

        .pokemon{
            display: flex;
            flex-direction: column;
            align-items: center;
            border: 1px solid rgb(0,0,0, 0.3);
            border-radius: 25px;
            position: relative;
            
            &:hover{
                box-shadow: 5px 10px 8px #888888;
            }

            img{
                size: 90px;
            }
            p{
                padding-bottom: 10px;
                font-size: 10pt;
            }
            
            &.searched-pokemon {
                border: 2px solid #32db8f;
                background: linear-gradient(135deg, #f0fff8 0%, #e8fef5 100%);
                
                .search-indicator {
                    position: absolute;
                    top: 5px;
                    right: 5px;
                    background: #32db8f;
                    color: white;
                    font-size: 8pt;
                    padding: 2px 6px;
                    border-radius: 10px;
                    font-weight: bold;
                }
            }
        }
    }


    .search-box{
        padding: 0 2vw;
        width: 100vw;
        height: 6vh;
        display: flex;
        gap: 1vw;
        
        input{
            all: unset;
            &[type="search"]{
                flex: 1;
                height: 90%;
                font-size: 13pt;
                text-align: center;
                border-radius: 25px;
                border: 1px solid black;
                padding: 0 10px;
            }
            &:focus::placeholder{
                color: transparent;
            }
            &:focus{
                outline: none;
                font-size: 16pt;
            }
        }
        
        .search-btn, .clear-btn {
            width: 12vw;
            height: 98%;
            padding: 0;
            border: 1px solid #ccc;
            border-radius: 4px;
            background: white;
            transition: all 0.2s ease;
            
            svg {
                height: 14pt;
                width: 14pt;
            }
            
            &:hover:not(:disabled) {
                background: #f0f0f0;
            }
            
            &:disabled {
                opacity: 0.5;
                cursor: not-allowed;
            }
        }
        
        .search-btn {
            background: #32db8f;
            color: white;
            border-color: #32db8f;
            
            &:hover:not(:disabled) {
                background: #28b878;
            }
        }
        
        .clear-btn {
            background: #ff6b6b;
            color: white;
            border-color: #ff6b6b;
            
            &:hover {
                background: #ff5252;
            }
        }
    }

    .no-results {
        text-align: center;
        padding: 40px 20px;
        color: #666;
        font-size: 16pt;
        
        p {
            margin: 10px 0;
            
            &.search-hint {
                font-size: 12pt;
                color: #999;
                font-style: italic;
            }
        }
    }

    .evolution-info {
        background: #4A90E2;
        color: white;
        padding: 10px 20px;
        margin: 10px 20px;
        border-radius: 8px;
        text-align: center;
        font-size: 14pt;
        
        p {
            margin: 0;
        }
    }

    .active-filter {
        background: #32db8f;
        color: white;
        padding: 10px 20px;
        margin: 10px 20px;
        border-radius: 8px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-size: 14pt;
        
        .clear-active-filter {
            background: rgba(255, 255, 255, 0.2);
            color: white;
            border: 1px solid rgba(255, 255, 255, 0.3);
            padding: 5px 12px;
            border-radius: 4px;
            font-size: 12pt;
            cursor: pointer;
            transition: background 0.2s ease;
            
            &:hover {
                background: rgba(255, 255, 255, 0.3);
            }
        }
    }

    // Filter Modal Styles
    .filter-modal-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100vw;
        height: 100vh;
        background: rgba(0, 0, 0, 0.7);
        display: flex;
        justify-content: center;
        align-items: center;
        z-index: 1000;
    }

    .filter-modal {
        background: white;
        border-radius: 15px;
        width: 90vw;
        max-width: 500px;
        max-height: 80vh;
        overflow-y: auto;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
    }

    .filter-modal-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 20px;
        border-bottom: 1px solid #eee;
        
        h2 {
            margin: 0;
            color: #333;
            font-size: 18pt;
        }
        
        .close-modal {
            background: none;
            border: none;
            font-size: 20px;
            cursor: pointer;
            padding: 5px;
            
            svg {
                width: 20px;
                height: 20px;
            }
        }
    }

    .filter-modal-content {
        padding: 20px;
    }

    .type-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 15px;
        margin-bottom: 30px;
    }

    .type-button {
        display: flex;
        flex-direction: column;
        align-items: center;
        padding: 15px 10px;
        border: 2px solid #ddd;
        border-radius: 10px;
        background: white;
        cursor: pointer;
        transition: all 0.2s ease;
        
        img {
            width: 30px;
            height: 30px;
            margin-bottom: 8px;
        }
        
        span {
            font-size: 11pt;
            font-weight: 500;
        }
        
        &:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }

        // Type-specific colors
        &.fire { border-color: #FF6B6B; &:hover { background: #FFF5F5; } }
        &.water { border-color: #4ECDC4; &:hover { background: #F0FDFC; } }
        &.grass { border-color: #95E1A3; &:hover { background: #F0FFF4; } }
        &.electric { border-color: #FFE66D; &:hover { background: #FFFBF0; } }
        &.psychic { border-color: #FF8CC8; &:hover { background: #FFF0F8; } }
        &.ice { border-color: #74C0FC; &:hover { background: #F0F8FF; } }
        &.dragon { border-color: #845EC2; &:hover { background: #F8F0FF; } }
        &.dark { border-color: #6C757D; &:hover { background: #F8F9FA; } }
        &.fighting { border-color: #FF6B6B; &:hover { background: #FFF5F5; } }
        &.poison { border-color: #B197FC; &:hover { background: #FAF5FF; } }
        &.ground { border-color: #D4A574; &:hover { background: #FDF8F0; } }
        &.flying { border-color: #91A7FF; &:hover { background: #F0F4FF; } }
        &.bug { border-color: #8CE99A; &:hover { background: #F0FFF4; } }
        &.rock { border-color: #ADB5BD; &:hover { background: #F8F9FA; } }
        &.ghost { border-color: #9775FA; &:hover { background: #FAF5FF; } }
        &.steel { border-color: #ADB5BD; &:hover { background: #F8F9FA; } }
        &.fairy { border-color: #FFA8CC; &:hover { background: #FFF0F6; } }
        &.normal { border-color: #CED4DA; &:hover { background: #F8F9FA; } }
    }

    .filter-actions {
        text-align: center;
        
        .clear-filter-btn {
            background: #6C757D;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            font-size: 14pt;
            cursor: pointer;
            transition: background 0.2s ease;
            
            &:hover {
                background: #5A6268;
            }
        }
    }
}

/* Responsive Splash Screen */
@media (max-width: 480px) {
    .splash-title {
        font-size: 28pt;
    }
    
    .splash-pokeball {
        width: 100px;
        height: 100px;
    }
    
    .splash-instruction {
        font-size: 16pt;
    }
}

@media (min-width: 1200px) {
    .splash-title {
        font-size: 42pt;
    }
    
    .splash-pokeball {
        width: 150px;
        height: 150px;
    }
    
    .splash-instruction {
        font-size: 20pt;
    }
}

/* Media query for tablets */
@media (min-width: 450px) {

    main {
        .poke-card-outer{
            position: fixed;
            top: 0;
            left: 0;
            z-index: 10;
            color: black;
            width: 100vw;
            height: 100vh;
            background: rgba(0, 0, 0, 0.7);
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .pokemon-card{
            position: relative;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            color: black;
            max-width: 90vw;
            max-height: 90vh;
            
            .exit-pk{
                position: absolute;
                top: 8px;
                right: 8px;
                width: 32px;
                height: 32px;
                background: rgba(0, 0, 0, 0.6);
                backdrop-filter: blur(10px);
                border: 2px solid rgba(255, 255, 255, 0.2);
                border-radius: 8px;
                cursor: pointer;
                z-index: 11;
                display: flex;
                align-items: center;
                justify-content: center;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
                transition: all 0.3s ease;
                
                svg {
                    width: 16px;
                    height: 16px;
                    fill: rgba(255, 255, 255, 0.9);
                    transition: fill 0.2s ease;
                }
                
                &:hover {
                    background: rgba(0, 0, 0, 0.8);
                    border-color: rgba(255, 255, 255, 0.4);
                    transform: scale(1.05);
                    
                    svg {
                        fill: white;
                    }
                }
            }

            .pokemon-top-card{
                display: flex;
                flex-direction: column;
                background: white;
                width: 80vw;
                height: 85vh;
                max-height: 100%;
                border: 2vw solid yellow;
                border-radius: 10px;
                align-items: center;
                box-shadow: inset 0 0 40px rgba(255, 255, 255, 0.5);
                .pk-bg-img-span{
                    background-image: url('/icons/gal2.png');
                    background-size: cover; /* or other values like 'contain' */
                    background-position: center center; /* or other positions */
                    background-repeat: no-repeat;
                    width: 90%; display: flex; 
                    justify-content: center; 
                    border: 1vw solid yellow; 
                    background-color: white;
                }
                .pk-img{
                    width: 65%;
                }
                .pk-card-header{
                    display: flex;
                    justify-content: space-between;
                    width: 98%;
                    margin: 7px;
                    .pk-header-name{
                        font-size: 25pt; 
                        font-weight: normal; 
                        margin: 4px;
                        margin-left: 30px;
                    }
                    .pk-header-stats-right{
                        width: 30%; 
                        display: flex; 
                        align-items: center; 
                        justify-content: space-around;
                        & span:nth-child(1){
                            font-size: 20pt;
                        }
                        & span:nth-child(2){
                            font-weight: normal; 
                            font-size: 22pt;
                        }
                        & img{
                            height: 35pt; 
                            margin: 0; 
                            padding: 0; 
                            border: yellow 2px solid; 
                            border-radius: 50px;
                        }
                    }
                }
                .pk-stats{
                    display: flex; 
                    font-size: 10pt;
                    justify-content: space-between; 
                    width: 45%; 
                    min-width: 180px;
                    background: yellow;
                    box-shadow: inset 0 0 30px rgba(255, 255, 255, 0.5);
                }
                .pk-card-stats{
                    margin-top: 30px;
                    width: 90%;
                    height: 25%;
                    display: flex;
                    flex-direction: column;
                    justify-content: space-evenly;
                    font-size: 20pt;

                    .pk-moves{
                        display: flex;
                        justify-content: space-between;
                    }
                }
            }
        }
        .page-buttons{
            padding: 6vh 0;
            display: flex;
            width: 100vw;
            justify-content: center;

            & > button{
                width: 20%;
                font-size: 15pt;
            }
        }
    }
}

@media (min-width: 768px) {

    main {
        .poke-card-outer{
            position: fixed;
            top: 0;
            left: 0;
            z-index: 10;
            color: black;
            width: 100vw;
            height: 100vh;
            background: rgba(0, 0, 0, 0.7);
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .pokemon-card{
            position: relative;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            color: black;
            max-width: 70vw;
            max-height: 85vh;
            
            .exit-pk{
                position: absolute;
                top: 10px;
                right: 10px;
                width: 36px;
                height: 36px;
                background: rgba(0, 0, 0, 0.6);
                backdrop-filter: blur(10px);
                border: 2px solid rgba(255, 255, 255, 0.2);
                border-radius: 8px;
                cursor: pointer;
                z-index: 11;
                display: flex;
                align-items: center;
                justify-content: center;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
                transition: all 0.3s ease;
                
                svg {
                    width: 18px;
                    height: 18px;
                    fill: rgba(255, 255, 255, 0.9);
                    transition: fill 0.2s ease;
                }
                
                &:hover {
                    background: rgba(0, 0, 0, 0.8);
                    border-color: rgba(255, 255, 255, 0.4);
                    transform: scale(1.05);
                    
                    svg {
                        fill: white;
                    }
                }
            }

            .pokemon-top-card{
                display: flex;
                flex-direction: column;
                background: white;
                width: 60vw;
                height: 100vh;
                max-height: 100%;
                border: 1vw solid yellow;
                border-radius: 10px;
                align-items: center;
                box-shadow: inset 0 0 40px rgba(255, 255, 255, 0.5);
                .pk-bg-img-span{
                    background-image: url('/icons/gal2.png');
                    background-size: cover; /* or other values like 'contain' */
                    background-position: center center; /* or other positions */
                    background-repeat: no-repeat;
                    width: 90%; display: flex; 
                    justify-content: center; 
                    border: 1vw solid yellow; 
                    background-color: white;
                }
                .pk-img{
                    width: 65%;
                }
                .pk-card-header{
                    display: flex;
                    justify-content: space-between;
                    width: 98%;
                    margin: 7px;
                    .pk-header-name{
                        font-size: 25pt; 
                        font-weight: normal; 
                        margin: 4px;
                        margin-left: 30px;
                    }
                    .pk-header-stats-right{
                        width: 30%; 
                        display: flex; 
                        align-items: center; 
                        justify-content: space-around;
                        & span:nth-child(1){
                            font-size: 20pt;
                        }
                        & span:nth-child(2){
                            font-weight: normal; 
                            font-size: 22pt;
                        }
                        & img{
                            height: 45pt; 
                            margin: 0; 
                            padding: 0; 
                            border: yellow 2px solid; 
                            border-radius: 50px;
                        }
                    }
                }
                .pk-stats{
                    display: flex; 
                    font-size: 12pt;
                    justify-content: space-between; 
                    width: 45%; 
                    min-width: 180px;
                    background: yellow;
                    box-shadow: inset 0 0 30px rgba(255, 255, 255, 0.5);
                }
                .pk-card-stats{
                    margin-top: 30px;
                    width: 90%;
                    height: 25%;
                    display: flex;
                    flex-direction: column;
                    justify-content: space-evenly;
                    font-size: 20pt;

                    .pk-moves{
                        display: flex;
                        justify-content: space-between;
                    }
                }
            }
        }
        .page-buttons{
            padding: 6vh 0;
            display: flex;
            width: 100vw;
            justify-content: center;

            & > button{
                width: 20%;
                font-size: 15pt;
            }
        }
    }
}

/* Media query for desktop screens */
@media (min-width: 1000px) {
    main {
        .poke-card-outer{
            position: fixed;
            top: 0;
            left: 0;
            z-index: 10;
            color: black;
            width: 100vw;
            height: 100vh;
            background: rgba(0, 0, 0, 0.7);
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .pokemon-card{
            position: relative;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            color: black;
            max-width: 60vw;
            max-height: 80vh;
            
            .exit-pk{
                position: absolute;
                top: 10px;
                right: 10px;
                width: 40px;
                height: 40px;
                background: rgba(0, 0, 0, 0.6);
                backdrop-filter: blur(10px);
                border: 2px solid rgba(255, 255, 255, 0.2);
                border-radius: 8px;
                cursor: pointer;
                z-index: 11;
                display: flex;
                align-items: center;
                justify-content: center;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
                transition: all 0.3s ease;
                
                svg {
                    width: 20px;
                    height: 20px;
                    fill: rgba(255, 255, 255, 0.9);
                    transition: fill 0.2s ease;
                }
                
                &:hover {
                    background: rgba(0, 0, 0, 0.8);
                    border-color: rgba(255, 255, 255, 0.4);
                    transform: scale(1.05);
                    
                    svg {
                        fill: white;
                    }
                }
            }

            .pokemon-top-card{
                display: flex;
                flex-direction: column;
                background: white;
                width: 50vw;
                height: 100vh;
                max-height: 100%;
                border: 1vw solid yellow;
                border-radius: 10px;
                align-items: center;
                box-shadow: inset 0 0 40px rgba(255, 255, 255, 0.5);
                .pk-bg-img-span{
                    background-image: url('/icons/gal2.png');
                    background-size: cover; /* or other values like 'contain' */
                    background-position: center center; /* or other positions */
                    background-repeat: no-repeat;
                    width: 90%; display: flex; 
                    justify-content: center; 
                    border: 1vw solid yellow; 
                    background-color: white;
                }
                .pk-img{
                    width: 65%;
                }
                .pk-card-header{
                    display: flex;
                    justify-content: space-between;
                    width: 98%;
                    margin: 7px;
                    .pk-header-name{
                        font-size: 25pt; 
                        font-weight: normal; 
                        margin: 4px;
                        margin-left: 30px;
                    }
                    .pk-header-stats-right{
                        width: 30%; 
                        display: flex; 
                        align-items: center; 
                        justify-content: space-around;
                        & span:nth-child(1){
                            font-size: 20pt;
                        }
                        & span:nth-child(2){
                            font-weight: normal; 
                            font-size: 22pt;
                        }
                        & img{
                            height: 45pt; 
                            margin: 0; 
                            padding: 0; 
                            border: yellow 2px solid; 
                            border-radius: 50px;
                        }
                    }
                }
                .pk-stats{
                    display: flex; 
                    font-size: 15pt;
                    justify-content: space-between; 
                    width: 45%; 
                    min-width: 180px;
                    background: yellow;
                    box-shadow: inset 0 0 30px rgba(255, 255, 255, 0.5);
                }
                .pk-card-stats{
                    margin-top: 30px;
                    width: 90%;
                    height: 25%;
                    display: flex;
                    flex-direction: column;
                    justify-content: space-evenly;
                    font-size: 20pt;

                    .pk-moves{
                        display: flex;
                        justify-content: space-between;
                    }
                }
            }
        }
        .page-buttons{
            padding: 6vh 0;
            display: flex;
            width: 100vw;
            justify-content: center;

            & > button{
                width: 20%;
                font-size: 15pt;
            }
        }
    }
}
@media (min-width: 1440px) {
    header{
        position: relative;
        z-index: 9000;
        display: flex;
        width: 100vw;
        background-color: $h-color;
        padding: 10px 0;
        h1{
            width: 95%;
            text-align: center;
            font-size: 28pt;
            margin-left: 110px;
            // &::selection{
            //     background: transparentize(#4299b8, 0.5);
            // }
        }
        .drop{
            width: 5%;
            margin-right: 100px;
            display: flex;
            justify-content: center;
            align-items: center;
            background-color: transparent;
            svg{
                font-size: 30pt;
            }
        }
    }

    main {
        .poke-card-outer{
            position: fixed;
            top: 0;
            left: 0;
            z-index: 10;
            color: black;
            width: 100vw;
            height: 100vh;
            background: rgba(0, 0, 0, 0.7);
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .pokemon-card{
            position: relative;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            color: black;
            max-width: 65vw;
            max-height: 85vh;
            
            .exit-pk{
                position: absolute;
                top: -15px;
                right: -15px;
                width: 44px;
                height: 44px;
                background: rgba(0, 0, 0, 0.6);
                backdrop-filter: blur(10px);
                border: 2px solid rgba(255, 255, 255, 0.2);
                border-radius: 8px;
                cursor: pointer;
                z-index: 11;
                display: flex;
                align-items: center;
                justify-content: center;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
                transition: all 0.3s ease;
                
                svg {
                    width: 22px;
                    height: 22px;
                    fill: rgba(255, 255, 255, 0.9);
                    transition: fill 0.2s ease;
                }
                
                &:hover {
                    background: rgba(0, 0, 0, 0.8);
                    border-color: rgba(255, 255, 255, 0.4);
                    transform: scale(1.05);
                    
                    svg {
                        fill: white;
                    }
                }
            }

            .pokemon-top-card{
                display: flex;
                flex-direction: column;
                background: white;
                width: 40vw;
                height: 100vh;
                max-height: 100%;
                border: 1vw solid yellow;
                border-radius: 10px;
                align-items: center;
                box-shadow: inset 0 0 40px rgba(255, 255, 255, 0.5);
                .pk-bg-img-span{
                    background-image: url('/icons/gal2.png');
                    background-size: cover; /* or other values like 'contain' */
                    background-position: center center; /* or other positions */
                    background-repeat: no-repeat;
                    width: 90%; display: flex; 
                    justify-content: center; 
                    border: 1vw solid yellow; 
                    background-color: white;
                }
                .pk-img{
                    width: 65%;
                }
                .pk-card-header{
                    display: flex;
                    justify-content: space-between;
                    width: 98%;
                    margin: 7px;
                    .pk-header-name{
                        font-size: 25pt; 
                        font-weight: normal; 
                        margin: 4px;
                        margin-left: 30px;
                    }
                    .pk-header-stats-right{
                        width: 30%; 
                        display: flex; 
                        align-items: center; 
                        justify-content: space-around;
                        & span:nth-child(1){
                            font-size: 20pt;
                        }
                        & span:nth-child(2){
                            font-weight: normal; 
                            font-size: 22pt;
                            margin-right: 30px;
                        }
                        & img{
                            height: 45pt; 
                            margin: 0; 
                            padding: 0; 
                            border: yellow 2px solid; 
                            border-radius: 50px;
                        }
                    }
                }
                .pk-stats{
                    display: flex; 
                    font-size: 15pt;
                    justify-content: space-between; 
                    width: 45%; 
                    min-width: 180px;
                    background: yellow;
                    box-shadow: inset 0 0 30px rgba(255, 255, 255, 0.5);
                }
                .pk-card-stats{
                    margin-top: 30px;
                    width: 90%;
                    height: 25%;
                    display: flex;
                    flex-direction: column;
                    justify-content: space-evenly;
                    font-size: 20pt;

                    .pk-moves{
                        display: flex;
                        justify-content: space-between;
                    }
                }
            }
        }
        .page-buttons{
            padding: 6vh 0;
            display: flex;
            width: 100vw;
            justify-content: center;

            & > button{
                width: 20%;
                font-size: 15pt;
            }
        }
    }
}

</style>