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
                <form class="pokemon" v-for="pm in pokemonList" :key="`poke` + pm.id">
                    <img :src=pm.img alt="pokemon image" loading="lazy">
                    <p>{{ pm.name }}</p>
                </form>
            </div>
            <!-- <div v-if="showFilteredList" class="pokemon-list">
                <form class="pokemon" v-for="pm in pokemonList" :key="`poke` + pm.id">
                    <img :src=pm.img alt="pokemon image">
                    <p>{{ pm.name }}</p>
                </form>
            </div> -->
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
const showList = ref(true);
const pokemonList = ref([]);
const nextPage = ref(null);
const previousPage = ref(null);
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
    isLoading.value = true;
    showList.value = false;
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
        // &:hover{
        //     background: transparentize(black, 0.7);
        // }
    }
}

main{
    padding-top: 2vh;

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
            position: relative;
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

