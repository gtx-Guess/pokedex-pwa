<template>
    <header>
        <h1>PWA-Pokedex</h1>
        <button class="drop">
            <svg xmlns="http://www.w3.org/2000/svg" height="1em" viewBox="0 0 448 512"><!--! Font Awesome Free 6.4.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2023 Fonticons, Inc. --><path d="M0 96C0 78.3 14.3 64 32 64H416c17.7 0 32 14.3 32 32s-14.3 32-32 32H32C14.3 128 0 113.7 0 96zM0 256c0-17.7 14.3-32 32-32H416c17.7 0 32 14.3 32 32s-14.3 32-32 32H32c-17.7 0-32-14.3-32-32zM448 416c0 17.7-14.3 32-32 32H32c-17.7 0-32-14.3-32-32s14.3-32 32-32H416c17.7 0 32 14.3 32 32z"/></svg>
        </button>
    </header>
    <main>
        <div class="search-box">
            <input type="search" name="Search" placeholder="     type pokemon name to search">
            <button class="filter">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><!--! Font Awesome Free 6.4.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2023 Fonticons, Inc. --><path d="M3.9 54.9C10.5 40.9 24.5 32 40 32H472c15.5 0 29.5 8.9 36.1 22.9s4.6 30.5-5.2 42.5L320 320.9V448c0 12.1-6.8 23.2-17.7 28.6s-23.8 4.3-33.5-3l-64-48c-8.1-6-12.8-15.5-12.8-25.6V320.9L9 97.3C-.7 85.4-2.8 68.8 3.9 54.9z"/></svg>
            </button>
        </div><br>
        <div v-if="isLoading" class="loading-spinner">
            <img class="pokeball" src="/pokeball.svg" alt="Svg Image">
            <p>Loading...</p>
        </div>
        <div v-else>
            <div v-if="showList" class="pokemon-list">
                <form class="pokemon" v-for="pm in pokemonList" :key="`poke` + pm.id" @click=pokemonCardClicked(pm)>
                    <img :src=pm.img alt="pokemon image" loading="lazy">
                    <p>{{ formatText(pm.name) }}</p>
                </form>
            </div>
            <!-- <div v-if="showFilteredList" class="pokemon-list">
                <form class="pokemon" v-for="pm in pokemonList" :key="`poke` + pm.id">
                    <img :src=pm.img alt="pokemon image">
                    <p>{{ pm.name }}</p>
                </form>
            </div> -->
        </div>
        <div v-if="pokeCardLoading" class="poke-card-loading">
                <img class="pokeball-img" src="/pokeball.svg" alt="Svg Image">
            </div>
        <div v-else>
            <div v-if="currentPokemon" class="poke-card-outer">
                <div class="pokemon-card">
                    <div class="pokemon-top-card" :style="{backgroundColor: pokeCardBG}">
                        <div class="pk-card-header">
                            <h1 style="font-size: 22pt; font-weight: normal; margin: 4px;">
                                {{ currentPokemon.name }}
                            </h1>
                            <div style="width: 35%; display: flex; align-items: center; justify-content: space-around;">
                                <span style="font-size: 16pt;">HP</span>
                                <span style="font-weight: normal; font-size: 18pt;">{{ currentPokemon.hp }}</span>
                                <img style="height: 30pt; margin: 0; padding: 0; border: yellow 1px solid; border-radius: 25px;" :src="'/icons/' + currentPokemon.type + '_type.png'" alt="type" loading="lazy">
                            </div>
                        </div>
                        <span class="pk-bg-img-span" style="width: 90%; display: flex; justify-content: center; border: 2vw solid yellow; background-color: white;"><img class="pk-img" :src=currentPokemon.img alt="pokemon image" loading="lazy"></span>
                        <div class="pk-stats">
                            <p>Height: {{ currentPokemon.ht }} ft</p>
                            <p>Weight: {{ currentPokemon.wt }} lb</p>
                        </div>
                        <div class="pk-card-stats">
                            <p class="pk-moves"><span>{{ currentPokemon.m1.name }}</span> <span>{{ currentPokemon.m1.power }}</span></p>
                            <p class="pk-moves"><span>{{ currentPokemon.m2.name }}</span> <span>{{ currentPokemon.m2.power }}</span></p>
                        </div>
                    </div>
                    <button class="exit-pk" @click="closePokemonCard">close</button>
                </div>
            </div>
        </div>
        <span class="page-buttons">
            <button v-if=" previousPage !== null " @click="getPokemonPage('Previous')">Previous Page</button>
            <button v-if=" nextPage !== null " @click="getPokemonPage('Next')">Next Page</button>
        </span>
    </main>
</template>

<script setup>
import { ref } from 'vue';

const P = new Pokedex.Pokedex();
const isLoading = ref(false);
const pokeCardLoading = ref(false);
const showList = ref(true);
const pokemonList = ref([]);
const nextPage = ref(null);
const previousPage = ref(null);
const currentPokemon = ref(null);
const pokeCardBG = ref('grey');
const imageUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/';

(async () => {
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
})();

const getPokemonPage = async (pageType) => {
    const page =  pageType === 'Next' ? nextPage.value : previousPage.value;
    if(!page){ return };
    pokeCardLoading.value = false;
    isLoading.value = true;
    showList.value = false;
    currentPokemon.value = null;
    let resp = await P.resource([ page ]);
    resp = resp[0];
    resp.results.forEach(p => {
        p.id = p.url.split('/').filter(( part ) => { return !!part }).pop();
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
    pokeCardLoading.value = true;
    const resp = await P.getPokemonByName(pokemon.name);
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

header{
    position: relative;
    z-index: 2000;
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

    .poke-card-outer{
        top: 7%;
        position: absolute;
        z-index: 10;
        color: black;
        width: 100vw;
        height: 107vh;
        background: rgba(0, 0, 0, 0.498);
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
    .pokemon-card{
        display: flex;
        top: 5%;
        flex-direction: column;
        justify-content: space-between;
        align-items: center;
        position: absolute;
        color: black;
        width: 100vw;
        height: 100vh;
        .exit-pk{
            position: absolute;
            width: 25vw;
            height: 6vh;
            top: 80%;
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
            }
            .pk-img{
                width: 65%;
            }
            .pk-card-header{
                display: flex;
                justify-content: space-between;
                width: 98%;
                margin: 7px;
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
        }
    }


    .search-box{
        padding: 0 2vw;
        width: 100vw;
        height: 6vh;
        // background-color: rgb(0,0,0,0.3);
        display: flex;
        input{
            all: unset;
            &[type="search"]{
                width: 82vw;
                height: 90%;
                font-size: 13pt;
                text-align: center;
                border-radius: 25px;
                border: 1px solid black;
                // background-color: rgb(100, 100, 100, 0.3);
            }
            &:focus::placeholder{
                color: transparent;
            }
            &:focus{
                outline: none;
                font-size: 20pt;
                
            }
        }
        .mag-glass{
            position: absolute;
            height: 18pt;
            left: 20px;
            top: 83px;
        }
        .submit{
            margin-left: 1vw;
            width: 10vw;
            height: 100%;
        }
        .filter{
            margin-left: 2vw;
            width: 13vw;
            height: 98%;
            padding: 0;
            margin-bottom: 0;
            svg{
                height: 14pt;
                // font-size: 12pt;
            }
        }
    }
}


</style>

