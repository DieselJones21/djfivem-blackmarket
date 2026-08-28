const inGame = Boolean(window.invokeNative);

const demoCatalog = {
    shop: 'dealer',
    title: 'Black Market',
    subtitle: 'Top of the world. Cash is always more expensive than dirty money.',
    money: { cash: 250000, black_money: 180000 },
    categories: [
        { id: 'pistols', label: 'Pistols' },
        { id: 'ars', label: 'ARs' },
        { id: 'ammo', label: 'Ammo' },
        { id: 'bm', label: 'BM Items' },
    ],
    items: [
        { category: 'pistols', item: 'WEAPON_SNAKEAP', label: 'Snake AP', description: 'Neon snakeskin AP pistol.', priceBlack: 75000, priceCash: 115000, max: 1, defaultAmount: 1, image: 'images/WEAPON_SNAKEAP.png' },
        { category: 'pistols', item: 'WEAPON_PATRICKSEMI', label: 'Patrick Semi', description: 'Pink-and-green custom semi.', priceBlack: 70000, priceCash: 105000, max: 1, defaultAmount: 1, image: 'images/WEAPON_PATRICKSEMI.png' },
        { category: 'pistols', item: 'WEAPON_DEVILAP', label: 'Devil AP', description: 'White slide, ruby crystal frame.', priceBlack: 90000, priceCash: 135000, max: 1, defaultAmount: 1, image: 'images/WEAPON_DEVILAP.png' },
        { category: 'pistols', item: 'WEAPON_SINISTERRED', label: 'Sinister Red', description: 'Black-and-red drum AP.', priceBlack: 95000, priceCash: 145000, max: 1, defaultAmount: 1, image: 'images/WEAPON_SINISTERRED.png' },
        { category: 'ars', item: 'WEAPON_PINKWIRESMG', label: 'Pink Wire SMG', description: 'Wireframe SMG with neon pink guts.', priceBlack: 140000, priceCash: 210000, max: 1, defaultAmount: 1, image: 'images/WEAPON_PINKWIRESMG.png' },
        { category: 'ars', item: 'WEAPON_KISSAR', label: 'Kiss AR', description: 'White rifle covered in lipstick marks.', priceBlack: 155000, priceCash: 235000, max: 1, defaultAmount: 1, image: 'images/WEAPON_KISSAR.png' },
        { category: 'ars', item: 'WEAPON_HAZARDAR', label: 'Hazard AR', description: 'Yellow-and-black caution rifle.', priceBlack: 165000, priceCash: 250000, max: 1, defaultAmount: 1, image: 'images/WEAPON_HAZARDAR.png' },
        { category: 'ars', item: 'WEAPON_CHROMEWIRESMG', label: 'Chrome Wire SMG', description: 'Chrome body, honeycomb suppressor.', priceBlack: 150000, priceCash: 225000, max: 1, defaultAmount: 1, image: 'images/WEAPON_CHROMEWIRESMG.png' },
        { category: 'ammo', item: 'ammo-9', label: '9mm Ammo', description: 'Pistol rounds. Sold per round.', priceBlack: 8, priceCash: 12, max: 250, defaultAmount: 30, image: 'images/ammo-9.png' },
        { category: 'ammo', item: 'ammo-44', label: '.44 Ammo', description: 'Heavy pistol rounds.', priceBlack: 12, priceCash: 18, max: 120, defaultAmount: 24, image: 'images/ammo-44.png' },
        { category: 'ammo', item: 'ammo-rifle', label: 'Rifle Ammo', description: 'Rifle cartridges.', priceBlack: 10, priceCash: 15, max: 250, defaultAmount: 30, image: 'images/ammo-rifle.png' },
        { category: 'ammo', item: 'ammo-shotgun', label: 'Shotgun Ammo', description: '12-gauge shells.', priceBlack: 15, priceCash: 22, max: 80, defaultAmount: 16, image: 'images/ammo-shotgun.png' },
        { category: 'ammo', item: 'ammo-50', label: '.50 Ammo', description: 'Heavy .50 rounds.', priceBlack: 25, priceCash: 38, max: 60, defaultAmount: 12, image: 'images/ammo-50.png' },
        { category: 'bm', item: 'robbery_tablet', label: 'Robbery Tablet', description: 'Encrypted tablet used to run jobs.', priceBlack: 12500, priceCash: 19000, max: 5, defaultAmount: 1, image: 'images/robbery_tablet.png' },
        { category: 'bm', item: 'lockpick', label: 'Lockpick', description: 'Slim-jim set.', priceBlack: 350, priceCash: 525, max: 10, defaultAmount: 1, image: 'images/lockpick.png' },
        { category: 'bm', item: 'veh_pinkslip', label: 'Vehicle Pink Slip', description: 'Paper for moving a vehicle off the books.', priceBlack: 35000, priceCash: 52500, max: 3, defaultAmount: 1, image: 'images/veh_pinkslip.png' },
        { category: 'bm', item: 'blackmarket_gps', label: 'Black Market GPS', description: 'Marks the mountain dealer on your map.', priceBlack: 4000, priceCash: 6500, max: 5, defaultAmount: 1, image: 'images/blackmarket_gps.png' },
    ],
};

const state = {
    shop: 'dealer',
    category: null,
    items: [],
    selected: null,
    amount: 1,
    money: { cash: 0, black_money: 0 },
    buying: false,
};

const els = {
    app: document.getElementById('app'),
    title: document.getElementById('shop-title'),
    subtitle: document.getElementById('shop-subtitle'),
    categories: document.getElementById('categories'),
    grid: document.getElementById('grid'),
    detail: document.getElementById('detail'),
    cash: document.getElementById('money-cash'),
    black: document.getElementById('money-black'),
    close: document.getElementById('btn-close'),
};

function money(n) {
    return '$' + Math.floor(Number(n) || 0).toLocaleString('en-US');
}

function nui(name, data) {
    if (!inGame) {
        return Promise.resolve({ ok: true, demo: true });
    }
    return fetch(`https://${GetParentResourceName()}/${name}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data || {}),
    }).then((res) => res.json()).catch(() => ({ ok: false }));
}

function closeUi() {
    els.app.classList.add('hidden');
    nui('close');
}

function setMoney(wallet) {
    state.money = wallet || state.money;
    els.cash.textContent = money(state.money.cash);
    els.black.textContent = money(state.money.black_money);
}

function itemsInCategory() {
    return state.items.filter((item) => item.category === state.category);
}

function renderCategories(categories) {
    els.categories.innerHTML = '';
    categories.forEach((cat) => {
        const btn = document.createElement('button');
        btn.className = 'cat' + (cat.id === state.category ? ' active' : '');
        btn.textContent = cat.label;
        btn.addEventListener('click', () => {
            state.category = cat.id;
            state.selected = null;
            renderCategories(categories);
            renderGrid();
            renderDetail();
        });
        els.categories.appendChild(btn);
    });
}

function renderGrid() {
    els.grid.innerHTML = '';
    itemsInCategory().forEach((item) => {
        const card = document.createElement('button');
        card.type = 'button';
        card.className = 'card' + (state.selected && state.selected.item === item.item ? ' selected' : '');
        card.innerHTML = `
            <img src="${item.image}" alt="${item.label}" />
            <h3>${item.label}</h3>
            <div class="prices">
                <span class="dirty">${money(item.priceBlack)}</span>
                <span class="cash">${money(item.priceCash)}</span>
            </div>
        `;
        card.addEventListener('click', () => {
            state.selected = item;
            state.amount = item.defaultAmount || 1;
            renderGrid();
            renderDetail();
        });
        els.grid.appendChild(card);
    });
}

function renderDetail() {
    const item = state.selected;
    if (!item) {
        els.detail.classList.add('empty');
        els.detail.innerHTML = '<p class="detail-placeholder">Pick something. Don\'t linger.</p>';
        return;
    }

    els.detail.classList.remove('empty');
    const blackTotal = item.priceBlack * state.amount;
    const cashTotal = item.priceCash * state.amount;
    const canBlack = state.money.black_money >= blackTotal;
    const canCash = state.money.cash >= cashTotal;

    els.detail.innerHTML = `
        <img src="${item.image}" alt="${item.label}" />
        <h2>${item.label}</h2>
        <p class="desc">${item.description || ''}</p>
        <div class="qty">
            <span>Amount</span>
            <div class="stepper">
                <button type="button" id="qty-minus">-</button>
                <input id="qty-input" type="number" min="1" max="${item.max}" value="${state.amount}" />
                <button type="button" id="qty-plus">+</button>
            </div>
        </div>
        <div class="pay">
            <button class="black" ${canBlack ? '' : 'disabled'} data-method="black_money">
                Black Money · ${money(blackTotal)}
            </button>
            <button class="clean" ${canCash ? '' : 'disabled'} data-method="cash">
                Cash · ${money(cashTotal)}
            </button>
        </div>
    `;

    const input = document.getElementById('qty-input');
    const clamp = (value) => {
        let next = Math.floor(Number(value) || 1);
        if (next < 1) next = 1;
        if (next > item.max) next = item.max;
        state.amount = next;
        renderDetail();
    };

    document.getElementById('qty-minus').addEventListener('click', () => clamp(state.amount - 1));
    document.getElementById('qty-plus').addEventListener('click', () => clamp(state.amount + 1));
    input.addEventListener('change', () => clamp(input.value));

    els.detail.querySelectorAll('.pay button').forEach((btn) => {
        btn.addEventListener('click', () => buy(btn.dataset.method));
    });
}

async function buy(method) {
    if (!state.selected || state.buying) return;
    state.buying = true;
    const result = await nui('purchase', {
        shop: state.shop,
        item: state.selected.item,
        amount: state.amount,
        method,
    });
    state.buying = false;

    if (result && result.ok) {
        if (result.money) setMoney(result.money);
        if (!inGame) {
            const price = method === 'cash' ? state.selected.priceCash : state.selected.priceBlack;
            const key = method === 'cash' ? 'cash' : 'black_money';
            state.money[key] = Math.max(0, state.money[key] - price * state.amount);
            setMoney(state.money);
        }
        renderDetail();
        return;
    }

    renderDetail();
}

function openShop(data) {
    state.shop = data.shop || 'dealer';
    state.items = data.items || [];
    state.category = (data.categories && data.categories[0] && data.categories[0].id) || 'pistols';
    state.selected = null;
    state.amount = 1;
    setMoney(data.money || { cash: 0, black_money: 0 });
    els.title.textContent = data.title || 'Black Market';
    els.subtitle.textContent = data.subtitle || '';
    renderCategories(data.categories || []);
    renderGrid();
    renderDetail();
    els.app.classList.remove('hidden');
}

els.close.addEventListener('click', closeUi);

window.addEventListener('keydown', (event) => {
    if (event.key === 'Escape' && !els.app.classList.contains('hidden')) {
        closeUi();
    }
});

window.addEventListener('message', (event) => {
    const payload = event.data || {};
    if (payload.action === 'open') {
        openShop(payload.data || {});
    }
    if (payload.action === 'close') {
        els.app.classList.add('hidden');
    }
});

if (!inGame) {
    openShop(demoCatalog);
}
