// Generate a random array and display it
function generateArray() {
    const container = document.getElementById('array-container');
    container.innerHTML = '';
    const array = [];
    for (let i = 0; i < 20; i++) {
        array.push(Math.floor(Math.random() * 100) + 1);
    }
    array.forEach(value => {
        const bar = document.createElement('div');
        bar.className = 'bar';
        bar.style.height = `${value * 3}px`;
        container.appendChild(bar);
    });
}

// Bubble Sort algorithm with visualization
async function bubbleSort() {
    const bars = document.querySelectorAll('.bar');
    for (let i = 0; i < bars.length - 1; i++) {
        for (let j = 0; j < bars.length - 1 - i; j++) {
            bars[j].style.backgroundColor = '#e74c3c';
            bars[j + 1].style.backgroundColor = '#e74c3c';
            await sleep(100);
            if (parseInt(bars[j].style.height) > parseInt(bars[j + 1].style.height)) {
                const temp = bars[j].style.height;
                bars[j].style.height = bars[j + 1].style.height;
                bars[j + 1].style.height = temp;
            }
            bars[j].style.backgroundColor = '#3498db';
            bars[j + 1].style.backgroundColor = '#3498db';
        }
        bars[bars.length - 1 - i].style.backgroundColor = '#2ecc71';
    }
    bars[0].style.backgroundColor = '#2ecc71';
}

// Helper function to pause execution
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

// Initial array generation
generateArray();