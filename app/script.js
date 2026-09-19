const API_URL = "https://goldgym.work.gd"


const hambugerMenu = document.querySelector(".harmbuger-menu")
const navItems = document.querySelector(".nav-items")

hambugerMenu.addEventListener("click", () => {
    hambugerMenu.classList.toggle("active")
    navItems.classList.toggle("active")
})

const initSlider = () => {
    const gymImage = document.querySelector(".gym-img");
    const slideButtons = document.querySelectorAll(".gym-slider .slidebutton");

    slideButtons.forEach(button => {
        button.addEventListener("click", () => {
            const direction = button.id === "prev-btn" ? -1 : 1;
            const scrollAmount = gymImage.clientWidth * direction;
            gymImage.scrollBy({ left: scrollAmount, behavior: "smooth"})
        })
    });
}

window.addEventListener("load", initSlider)

const secondSlider = () => {
    const gymImage2 = document.querySelector(".gym-image");
    const slideButtons = document.querySelectorAll(".gym-slider .slidebutton1");

    slideButtons.forEach(button => {
        button.addEventListener("click", () => {
            const direction = button.id === "prev-btn1" ? -1 : 1;
            const scrollAmount = gymImage2.clientWidth * direction;
            gymImage2.scrollBy({ left: scrollAmount, behavior: "smooth"})
        })
    });
}

window.addEventListener("load", secondSlider)

const thirdSlider = () => {
    const gymImage3 = document.querySelector(".gym-image1");
    const slideButtons = document.querySelectorAll(".gym-slider .slidebutton2");

    slideButtons.forEach(button => {
        button.addEventListener("click", () => {
            const direction = button.id === "prev-btn2" ? -1 : 1;
            const scrollAmount = gymImage3.clientWidth * direction;
            gymImage3.scrollBy({ left: scrollAmount, behavior: "smooth"})
        })
    });
}

window.addEventListener("load", thirdSlider)

const forthSlider = () => {
    const gymImage4 = document.querySelector(".gym-image2");
    const slideButtons = document.querySelectorAll(".gym-slider .slidebutton3");

    slideButtons.forEach(button => {
        button.addEventListener("click", () => {
            const direction = button.id === "prev-btn3" ? -1 : 1;
            const scrollAmount = gymImage4.clientWidth * direction;
            gymImage4.scrollBy({ left: scrollAmount, behavior: "smooth"})
        })
    });
}

window.addEventListener("load", forthSlider)

const fifthSlider = () => {
    const gymImage5 = document.querySelector(".gym-image3");
    const slideButtons = document.querySelectorAll(".gym-slider .slidebutton4");

    slideButtons.forEach(button => {
        button.addEventListener("click", () => {
            const direction = button.id === "prev-btn4" ? -1 : 1;
            const scrollAmount = gymImage5.clientWidth * direction;
            gymImage5.scrollBy({ left: scrollAmount, behavior: "smooth"})
        })
    });
}

window.addEventListener("load", fifthSlider)

document.querySelector(".store-btn").addEventListener("click", function(){
    document.querySelector(".popup").classList.add("active")
})

document.querySelector(".popup .close-button").addEventListener("click", function(){
    document.querySelector(".popup").classList.remove("active")
})