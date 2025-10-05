let currentView = 'inicio';
const views = ['inicio', 'palacio', 'biblioteca', 'mercado'];

document.addEventListener('DOMContentLoaded', () => {
    initializeApp();
    handleURLHash();
    setupEventListeners();
});

function initializeApp() {
    updateNavbar();
    addLoadingAnimations();
}

function handleURLHash() {
    const hash = window.location.hash.substring(1);
    if (hash && views.includes(hash)) {
        setTimeout(() => {
            navigateTo(hash);
        }, 100);
    } else {
        navigateTo('inicio');
    }
}

function setupEventListeners() {
    window.addEventListener('popstate', handleURLHash);
    
    document.querySelectorAll('.nav-link').forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const target = e.target.getAttribute('href').substring(1);
            navigateTo(target);
            
            document.querySelector('.nav-links').classList.remove('mobile-active');
        });
    });

    document.querySelector('.logo').addEventListener('click', () => {
        navigateTo('inicio');
    });

    setupNavbarScroll();

    setupMobileMenu();

    document.getElementById('qrModal').addEventListener('click', (e) => {
        if (e.target.id === 'qrModal') {
            closeModal();
        }
    });
}

// Efecto de scroll en navbar
function setupNavbarScroll() {
    let lastScroll = 0;
    window.addEventListener('scroll', () => {
        const navbar = document.getElementById('navbar');
        const currentScroll = window.pageYOffset;

        if (currentScroll > 100) {
            navbar.style.background = 'rgba(255, 255, 255, 0.98)';
            navbar.style.boxShadow = '0 4px 30px rgba(0, 0, 0, 0.15)';
        } else {
            navbar.style.background = 'rgba(255, 255, 255, 0.95)';
            navbar.style.boxShadow = '0 4px 20px rgba(0, 0, 0, 0.1)';
        }

        lastScroll = currentScroll;
    });
}

// Menú móvil
function setupMobileMenu() {
    const menuToggle = document.getElementById('menuToggle');
    const navLinks = document.querySelector('.nav-links');
    
    menuToggle.addEventListener('click', () => {
        navLinks.classList.toggle('mobile-active');
    });

    navLinks.querySelectorAll('a').forEach(link => {
        link.addEventListener('click', () => {
            navLinks.classList.remove('mobile-active');
        });
    });
}

function navigateTo(viewName) {
    if (!views.includes(viewName)) {
        console.error(`Vista "${viewName}" no existe`);
        return;
    }

    const currentElement = document.getElementById(currentView);
    if (currentElement) {
        currentElement.style.opacity = '0';
        setTimeout(() => {
            currentElement.classList.remove('active');
        }, 300);
    }

    setTimeout(() => {
        const newElement = document.getElementById(viewName);
        if (newElement) {
            newElement.classList.add('active');
            
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });

            currentView = viewName;
            
            history.pushState({ view: viewName }, '', `#${viewName}`);
            
            updateNavbar();

            animateView(viewName);
        }
    }, 300);
}

function updateNavbar() {
    document.querySelectorAll('.nav-link').forEach(link => {
        const target = link.getAttribute('href').substring(1);
        if (target === currentView) {
            link.classList.add('active');
        } else {
            link.classList.remove('active');
        }
    });
}

function animateView(viewName) {
    const view = document.getElementById(viewName);
    const elements = view.querySelectorAll('.lugar-content, .image-gallery, .info-section');
    
    elements.forEach((el, index) => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(30px)';
        
        setTimeout(() => {
            el.style.transition = 'all 0.6s ease';
            el.style.opacity = '1';
            el.style.transform = 'translateY(0)';
        }, index * 150);
    });
}

function addLoadingAnimations() {
    const fadeElements = document.querySelectorAll('.fade-in, .fade-in-delay, .fade-in-delay-2, .fade-in-delay-3');
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, {
        threshold: 0.1
    });

    fadeElements.forEach(el => {
        observer.observe(el);
    });
}

function showQRInfo() {
    const modal = document.getElementById('qrModal');
    modal.classList.add('active');
}

function closeModal() {
    const modal = document.getElementById('qrModal');
    modal.classList.remove('active');
}

function addParallaxEffect() {
    window.addEventListener('scroll', () => {
        const scrolled = window.pageYOffset;
        const parallaxElements = document.querySelectorAll('.image-placeholder');
        
        parallaxElements.forEach(el => {
            const speed = 0.5;
            el.style.transform = `translateY(${scrolled * speed}px)`;
        });
    });
}

document.addEventListener('click', (e) => {
    if (e.target.closest('.place-card')) {
        const card = e.target.closest('.place-card');
        card.style.transform = 'scale(0.95)';
        setTimeout(() => {
            card.style.transform = '';
        }, 200);
    }
});
