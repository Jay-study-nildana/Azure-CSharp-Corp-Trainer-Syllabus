//note, here you might see some 'red' errors, because this file is TypeScript
//and VS Code does not understand it directly
//but when the code is loaded in the browser, it will work just fine. 

// Generate a random array and display it
function generateArray(): void {
    const container: HTMLElement | null = document.getElementById('array-container');
    if (!container) return;
    container.innerHTML = '';
    const array: number[] = [];
    for (let i = 0; i < 20; i++) {
        array.push(Math.floor(Math.random() * 100) + 1);
    }
    array.forEach(value => {
        const bar: HTMLDivElement = document.createElement('div');
        bar.className = 'bar';
        bar.style.height = `${value * 3}px`;
        container.appendChild(bar);
    });
}

// Bubble Sort algorithm with visualization
async function bubbleSort(): Promise<void> {
    const bars: NodeListOf<HTMLDivElement> = document.querySelectorAll('.bar');
    for (let i = 0; i < bars.length - 1; i++) {
        for (let j = 0; j < bars.length - 1 - i; j++) {
            bars[j].style.backgroundColor = '#e74c3c';
            bars[j + 1].style.backgroundColor = '#e74c3c';
            await sleep(100);
            if (parseInt(bars[j].style.height) > parseInt(bars[j + 1].style.height)) {
                const temp: string = bars[j].style.height;
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
function sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
}

// Initial array generation
generateArray();