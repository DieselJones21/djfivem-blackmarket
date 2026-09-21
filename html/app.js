const inGame = Boolean(window.invokeNative);

const demoCatalog = {
    shop: 'dealer',
    title: 'Black Market',
    location: 'Miami',
    initials: '305',
    player: { name: 'Test Test', role: 'Connected' },
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
        { category: 'bm', item: 'blackmarket_gps', label: '305 GPS', description: 'Marks the 305 dealer on your map.', priceBlack: 4000, priceCash: 6500, max: 5, defaultAmount: 1, image: 'images/blackmarket_gps.png' },
    ],
};

const state = {
    shop: 'dealer',
    category: 'all',
    search: '',
    method: 'black_money',
    items: [],
    categories: [],
    qty: {},
    cart: [],
    money: { cash: 0, black_money: 0 },
    buying: false,
};

let toastTimer;

function $(id) {
    return document.getElementById(id);
}

function money(n) {
    return '$' + Math.floor(Number(n) || 0).toLocaleString('en-US');
}

function initials(name) {
    const parts = String(name || 'C').trim().split(/\s+/);
    const letters = (parts[0][0] || 'C') + (parts[1] ? parts[1][0] : '');
    return letters.toUpperCase();
}

function unitPrice(item) {
    return state.method === 'cash' ? item.priceCash : item.priceBlack;
}

function imgTag(item, extraClass) {
    const src = item.image || ('images/' + item.item + '.png');
    const fallback = 'images/' + item.item + '.png';
    const cls = extraClass ? ' class="' + extraClass + '"' : '';
    return '<img' + cls + ' src="' + src + '" alt="' + item.label + '" onerror="if(this.dataset.fallback)return;this.dataset.fallback=1;this.src=\'' + fallback + '\'" />';
}

function cartTotal() {
    return state.cart.reduce((sum, line) => sum + unitPrice(line.item) * line.amount, 0);
}

function cartCount() {
    return state.cart.reduce((sum, line) => sum + line.amount, 0);
}

function nui(name, data) {
    if (!inGame) {
        return Promise.resolve({ ok: true, demo: true });
    }
    const resource = (typeof GetParentResourceName === 'function' && GetParentResourceName()) || 'djfivem-blackmarket';
    return fetch(`https://${resource}/${name}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data || {}),
    }).then((res) => res.json()).catch(() => ({ ok: false }));
}

function toast(message) {
    const el = $('toast');
    el.textContent = message;
    el.classList.remove('hidden');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => el.classList.add('hidden'), 1800);
}

function closeUi() {
    $('app').classList.add('hidden');
    nui('close');
}

function setMoney(wallet) {
    state.money = wallet || state.money;
    $('money-cash').textContent = money(state.money.cash);
    $('money-black').textContent = money(state.money.black_money);
    renderTotals();
}

function visibleItems() {
    const query = state.search.trim().toLowerCase();
    return state.items.filter((item) => {
        if (state.category !== 'all' && item.category !== state.category) return false;
        if (!query) return true;
        return item.label.toLowerCase().includes(query) || item.item.toLowerCase().includes(query);
    });
}

function renderCategories() {
    const tabs = [{ id: 'all', label: 'All' }].concat(state.categories);
    $('categories').innerHTML = '';
    tabs.forEach((cat) => {
        const btn = document.createElement('button');
        btn.type = 'button';
        btn.className = 'tab' + (cat.id === state.category ? ' active' : '');
        btn.textContent = cat.label;
        btn.addEventListener('click', () => {
            state.category = cat.id;
            renderCategories();
            renderGrid();
        });
        $('categories').appendChild(btn);
    });
}

function renderGrid() {
    const items = visibleItems();
    $('catalog-count').textContent = items.length + (items.length === 1 ? ' item available' : ' items available');
    const grid = $('grid');
    grid.innerHTML = '';

    if (!items.length) {
        grid.innerHTML = '<p class="empty">No items found.</p>';
        return;
    }

    items.forEach((item) => {
        if (!state.qty[item.item]) {
            state.qty[item.item] = item.defaultAmount || 1;
        }
        const qty = state.qty[item.item];
        const card = document.createElement('article');
        card.className = 'card';
        card.innerHTML = `
            <div class="thumb">${imgTag(item)}</div>
            <h3>${item.label}</h3>
            <div class="price">${money(unitPrice(item))}</div>
            <div class="stepper">
                <button type="button" data-act="minus" ${qty <= 1 ? 'disabled' : ''}>−</button>
                <span>${qty}</span>
                <button type="button" data-act="plus" ${qty >= item.max ? 'disabled' : ''}>+</button>
            </div>
            <button type="button" class="add" data-act="add">Add to cart</button>
        `;
        card.addEventListener('click', (event) => {
            const act = event.target.dataset && event.target.dataset.act;
            if (act === 'minus') changeQty(item, -1);
            if (act === 'plus') changeQty(item, 1);
            if (act === 'add') addToCart(item, card.querySelector('.add'));
        });
        grid.appendChild(card);
    });
}

function changeQty(item, delta) {
    const next = (state.qty[item.item] || 1) + delta;
    state.qty[item.item] = Math.min(item.max, Math.max(1, next));
    renderGrid();
}

function addToCart(item, button) {
    const amount = state.qty[item.item] || 1;
    const existing = state.cart.find((line) => line.item.item === item.item);
    if (existing) {
        existing.amount = Math.min(item.max, existing.amount + amount);
    } else {
        state.cart.push({ item, amount });
    }
    if (button) {
        button.classList.add('added');
        button.textContent = 'Added';
        setTimeout(() => {
            button.classList.remove('added');
            button.textContent = 'Add to cart';
        }, 700);
    }
    toast('Added ' + item.label + ' to cart');
    renderCart();
}

function removeFromCart(itemName) {
    state.cart = state.cart.filter((line) => line.item.item !== itemName);
    renderCart();
}

function renderCart() {
    const list = $('cart-list');
    if (!state.cart.length) {
        list.innerHTML = '<p class="empty">Your cart is empty.</p>';
        renderTotals();
        return;
    }

    list.innerHTML = '';
    state.cart.forEach((line) => {
        const row = document.createElement('div');
        row.className = 'line';
        row.innerHTML = `
            ${imgTag(line.item)}
            <div>
                <h4>${line.item.label}</h4>
                <p>${line.amount} × ${money(unitPrice(line.item))}</p>
                <button type="button">Remove</button>
            </div>
            <strong>${money(unitPrice(line.item) * line.amount)}</strong>
        `;
        row.querySelector('button').addEventListener('click', () => removeFromCart(line.item.item));
        list.appendChild(row);
    });
    renderTotals();
}

function renderTotals() {
    const total = cartTotal();
    const count = cartCount();
    const label = state.method === 'cash' ? 'Cash' : 'Dirty Cash';
    const wallet = state.method === 'cash' ? state.money.cash : state.money.black_money;
    $('cart-total').textContent = money(total);
    $('cart-count').textContent = count + (count === 1 ? ' item' : ' items');
    $('method-label').textContent = label;
    $('method-total').textContent = money(total);
    $('btn-checkout').disabled = count === 0 || wallet < total || state.buying;
}

function setMethod(method) {
    state.method = method;
    $('pay-black').classList.toggle('active', method === 'black_money');
    $('pay-cash').classList.toggle('active', method === 'cash');
    renderGrid();
    renderCart();
}

async function checkout() {
    if (state.buying || !state.cart.length) return;
    const total = cartTotal();
    const wallet = state.method === 'cash' ? state.money.cash : state.money.black_money;
    if (wallet < total) {
        toast('Not enough ' + (state.method === 'cash' ? 'cash' : 'dirty cash'));
        return;
    }

    state.buying = true;
    renderTotals();
    const result = await nui('checkout', {
        shop: state.shop,
        method: state.method,
        cart: state.cart.map((line) => ({ item: line.item.item, amount: line.amount })),
    });
    state.buying = false;

    if (result && result.ok) {
        if (result.money) {
            setMoney(result.money);
        } else if (!inGame) {
            const key = state.method === 'cash' ? 'cash' : 'black_money';
            state.money[key] = Math.max(0, state.money[key] - total);
            setMoney(state.money);
        }
        state.cart = [];
        renderCart();
        toast('Purchase complete');
        return;
    }

    toast((result && result.error) || 'Checkout failed');
    renderTotals();
}

function openShop(data) {
    state.shop = data.shop || 'dealer';
    state.items = data.items || [];
    state.categories = data.categories || [];
    state.category = 'all';
    state.search = '';
    state.method = 'black_money';
    state.cart = [];
    state.qty = {};
    state.buying = false;

    $('shop-title').textContent = data.title || 'Black Market';
    $('shop-location').textContent = data.location || data.subtitle || 'Miami';

    const player = data.player || { name: 'Customer', role: 'Connected' };
    $('player-name').textContent = player.name || 'Customer';
    $('player-role').textContent = player.role || 'Connected';
    $('player-avatar').textContent = initials(player.name);

    $('search').value = '';
    setMoney(data.money || { cash: 0, black_money: 0 });
    setMethod('black_money');
    renderCategories();
    renderGrid();
    renderCart();
    $('app').classList.remove('hidden');
}

$('btn-close').addEventListener('click', closeUi);
$('btn-checkout').addEventListener('click', checkout);
$('pay-black').addEventListener('click', () => setMethod('black_money'));
$('pay-cash').addEventListener('click', () => setMethod('cash'));
$('search').addEventListener('input', (event) => {
    state.search = event.target.value;
    renderGrid();
});

window.addEventListener('keydown', (event) => {
    if (event.key === 'Escape' && !$('app').classList.contains('hidden')) {
        closeUi();
    }
});

window.addEventListener('message', (event) => {
    const payload = event.data || {};
    if (payload.action === 'open') openShop(payload.data || {});
    if (payload.action === 'close') $('app').classList.add('hidden');
});

if (!inGame) {
    document.body.classList.add('preview');
    openShop(demoCatalog);
}
