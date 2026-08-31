const inGame = Boolean(window.invokeNative);
const ITEM_ID = /^[A-Za-z0-9_-]{1,48}$/;
const MAX_CART_LINES = 8;

const demoCatalog = {
    shop: 'dealer',
    title: 'Black Market',
    location: 'Mount Chiliad',
    player: { name: 'Test Test', role: 'Customer' },
    money: { cash: 250000, black_money: 180000 },
    categories: [
        { id: 'pistols', label: 'Pistols' },
        { id: 'ars', label: 'ARs' },
        { id: 'ammo', label: 'Ammo' },
        { id: 'bm', label: 'BM Items' },
    ],
    items: [
        { category: 'pistols', item: 'WEAPON_SNAKEAP', label: 'Snake AP', priceBlack: 75000, priceCash: 115000, max: 1, defaultAmount: 1, image: 'images/WEAPON_SNAKEAP.png' },
        { category: 'pistols', item: 'WEAPON_PATRICKSEMI', label: 'Patrick Semi', priceBlack: 70000, priceCash: 105000, max: 1, defaultAmount: 1, image: 'images/WEAPON_PATRICKSEMI.png' },
        { category: 'pistols', item: 'WEAPON_DEVILAP', label: 'Devil AP', priceBlack: 90000, priceCash: 135000, max: 1, defaultAmount: 1, image: 'images/WEAPON_DEVILAP.png' },
        { category: 'pistols', item: 'WEAPON_SINISTERRED', label: 'Sinister Red', priceBlack: 95000, priceCash: 145000, max: 1, defaultAmount: 1, image: 'images/WEAPON_SINISTERRED.png' },
        { category: 'ars', item: 'WEAPON_PINKWIRESMG', label: 'Pink Wire SMG', priceBlack: 140000, priceCash: 210000, max: 1, defaultAmount: 1, image: 'images/WEAPON_PINKWIRESMG.png' },
        { category: 'ars', item: 'WEAPON_KISSAR', label: 'Kiss AR', priceBlack: 155000, priceCash: 235000, max: 1, defaultAmount: 1, image: 'images/WEAPON_KISSAR.png' },
        { category: 'ars', item: 'WEAPON_HAZARDAR', label: 'Hazard AR', priceBlack: 165000, priceCash: 250000, max: 1, defaultAmount: 1, image: 'images/WEAPON_HAZARDAR.png' },
        { category: 'ars', item: 'WEAPON_CHROMEWIRESMG', label: 'Chrome Wire SMG', priceBlack: 150000, priceCash: 225000, max: 1, defaultAmount: 1, image: 'images/WEAPON_CHROMEWIRESMG.png' },
        { category: 'ammo', item: 'ammo-9', label: '9mm Ammo', priceBlack: 8, priceCash: 12, max: 250, defaultAmount: 30, image: 'images/ammo-9.png' },
        { category: 'ammo', item: 'ammo-44', label: '.44 Ammo', priceBlack: 12, priceCash: 18, max: 120, defaultAmount: 24, image: 'images/ammo-44.png' },
        { category: 'ammo', item: 'ammo-rifle', label: 'Rifle Ammo', priceBlack: 10, priceCash: 15, max: 250, defaultAmount: 30, image: 'images/ammo-rifle.png' },
        { category: 'ammo', item: 'ammo-shotgun', label: 'Shotgun Ammo', priceBlack: 15, priceCash: 22, max: 80, defaultAmount: 16, image: 'images/ammo-shotgun.png' },
        { category: 'ammo', item: 'ammo-50', label: '.50 Ammo', priceBlack: 25, priceCash: 38, max: 60, defaultAmount: 12, image: 'images/ammo-50.png' },
        { category: 'bm', item: 'robbery_tablet', label: 'Robbery Tablet', priceBlack: 12500, priceCash: 19000, max: 5, defaultAmount: 1, image: 'images/robbery_tablet.png' },
        { category: 'bm', item: 'lockpick', label: 'Lockpick', priceBlack: 350, priceCash: 525, max: 10, defaultAmount: 1, image: 'images/lockpick.png' },
        { category: 'bm', item: 'veh_pinkslip', label: 'Vehicle Pink Slip', priceBlack: 35000, priceCash: 52500, max: 3, defaultAmount: 1, image: 'images/veh_pinkslip.png' },
        { category: 'bm', item: 'blackmarket_gps', label: 'Black Market GPS', priceBlack: 4000, priceCash: 6500, max: 5, defaultAmount: 1, image: 'images/blackmarket_gps.png' },
    ],
};

const state = {
    shop: 'dealer',
    category: 'all',
    search: '',
    method: 'black_money',
    items: [],
    itemMap: {},
    categories: [],
    qty: {},
    cart: [],
    money: { cash: 0, black_money: 0 },
    buying: false,
};

let toastTimer;
let searchTimer;

function $(id) {
    return document.getElementById(id);
}

function escapeHtml(value) {
    return String(value || '')
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}

function safeId(value) {
    const id = String(value || '');
    return ITEM_ID.test(id) ? id : '';
}

function money(n) {
    const amount = Math.floor(Number(n) || 0);
    return '$' + amount.toLocaleString('en-US');
}

function initials(name) {
    const parts = String(name || 'C').trim().split(/\s+/);
    return ((parts[0][0] || 'C') + (parts[1] ? parts[1][0] : '')).toUpperCase();
}

function unitPrice(item) {
    return state.method === 'cash' ? item.priceCash : item.priceBlack;
}

function imageSrc(item) {
    const id = safeId(item.item);
    if (item.image && (item.image.indexOf('nui://') === 0 || item.image.indexOf('images/') === 0)) {
        return item.image;
    }
    return id ? ('images/' + id + '.png') : '';
}

function imgTag(item) {
    const src = escapeHtml(imageSrc(item));
    const fallback = escapeHtml(safeId(item.item) ? ('images/' + item.item + '.png') : '');
    const alt = escapeHtml(item.label);
    return '<img src="' + src + '" alt="' + alt + '" onerror="if(this.dataset.fallback||!\'' + fallback + '\')return;this.dataset.fallback=1;this.src=\'' + fallback + '\'" />';
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
    return fetch('https://' + resource + '/' + name, {
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
    state.money = {
        cash: Math.max(0, Math.floor(Number(wallet && wallet.cash) || 0)),
        black_money: Math.max(0, Math.floor(Number(wallet && wallet.black_money) || 0)),
    };
    $('money-cash').textContent = money(state.money.cash);
    $('money-black').textContent = money(state.money.black_money);
    renderTotals();
}

function visibleItems() {
    const query = state.search.trim().toLowerCase();
    return state.items.filter((item) => {
        if (!safeId(item.item)) return false;
        if (state.category !== 'all' && item.category !== state.category) return false;
        if (!query) return true;
        return item.label.toLowerCase().includes(query) || item.item.toLowerCase().includes(query);
    });
}

function renderCategories() {
    const tabs = [{ id: 'all', label: 'All' }].concat(state.categories);
    const nav = $('categories');
    nav.innerHTML = '';
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
        nav.appendChild(btn);
    });
}

function qtyFor(item) {
    if (!state.qty[item.item]) {
        state.qty[item.item] = item.defaultAmount || 1;
    }
    return state.qty[item.item];
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

    const priceClass = state.method === 'cash' ? 'price cash' : 'price';
    const frag = document.createDocumentFragment();

    items.forEach((item) => {
        const qty = qtyFor(item);
        const card = document.createElement('article');
        card.className = 'card';
        card.dataset.item = item.item;
        card.innerHTML =
            '<div class="thumb">' + imgTag(item) + '</div>' +
            '<h3>' + escapeHtml(item.label) + '</h3>' +
            '<div class="' + priceClass + '">' + money(unitPrice(item)) + '</div>' +
            '<div class="stepper">' +
                '<button type="button" data-act="minus"' + (qty <= 1 ? ' disabled' : '') + '>−</button>' +
                '<span data-qty>' + qty + '</span>' +
                '<button type="button" data-act="plus"' + (qty >= item.max ? ' disabled' : '') + '>+</button>' +
            '</div>' +
            '<button type="button" class="add" data-act="add">Add to cart</button>';
        frag.appendChild(card);
    });

    grid.appendChild(frag);
}

function updateCardQty(item) {
    const card = $('grid').querySelector('[data-item="' + CSS.escape(item.item) + '"]');
    if (!card) return;
    const qty = qtyFor(item);
    const qtyEl = card.querySelector('[data-qty]');
    const minus = card.querySelector('[data-act="minus"]');
    const plus = card.querySelector('[data-act="plus"]');
    if (qtyEl) qtyEl.textContent = String(qty);
    if (minus) minus.disabled = qty <= 1;
    if (plus) plus.disabled = qty >= item.max;
}

function changeQty(item, delta) {
    const next = (qtyFor(item) || 1) + delta;
    state.qty[item.item] = Math.min(item.max, Math.max(1, next));
    updateCardQty(item);
}

function addToCart(item, button) {
    const amount = qtyFor(item);
    const existing = state.cart.find((line) => line.item.item === item.item);
    if (!existing && state.cart.length >= MAX_CART_LINES) {
        toast('Cart is full');
        return;
    }
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
    const frag = document.createDocumentFragment();
    state.cart.forEach((line) => {
        const row = document.createElement('div');
        row.className = 'line';
        row.innerHTML =
            imgTag(line.item) +
            '<div>' +
                '<h4>' + escapeHtml(line.item.label) + '</h4>' +
                '<p>' + line.amount + ' × ' + money(unitPrice(line.item)) + '</p>' +
                '<button type="button" data-remove="' + escapeHtml(line.item.item) + '">Remove</button>' +
            '</div>' +
            '<strong>' + money(unitPrice(line.item) * line.amount) + '</strong>';
        frag.appendChild(row);
    });
    list.appendChild(frag);
    renderTotals();
}

function renderTotals() {
    const total = cartTotal();
    const count = cartCount();
    const label = state.method === 'cash' ? 'Cash' : 'Black Money';
    const wallet = state.method === 'cash' ? state.money.cash : state.money.black_money;
    $('cart-total').textContent = money(total);
    $('cart-count').textContent = count + (count === 1 ? ' item' : ' items');
    $('method-label').textContent = label;
    $('method-total').textContent = money(total);
    $('btn-checkout').disabled = count === 0 || wallet < total || state.buying;
}

function setMethod(method) {
    state.method = method === 'cash' ? 'cash' : 'black_money';
    $('pay-black').classList.toggle('active', state.method === 'black_money');
    $('pay-cash').classList.toggle('active', state.method === 'cash');
    renderGrid();
    renderCart();
}

async function checkout() {
    if (state.buying || !state.cart.length) return;
    const total = cartTotal();
    const wallet = state.method === 'cash' ? state.money.cash : state.money.black_money;
    if (wallet < total) {
        toast('Not enough ' + (state.method === 'cash' ? 'cash' : 'black money'));
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

function sanitizeItems(items) {
    return (items || []).filter((item) => item && safeId(item.item) && item.label).map((item) => {
        const max = Math.max(1, Math.floor(Number(item.max) || 1));
        const defaultAmount = Math.min(max, Math.max(1, Math.floor(Number(item.defaultAmount) || 1)));
        return {
            category: String(item.category || ''),
            item: item.item,
            label: String(item.label),
            priceBlack: Math.max(0, Math.floor(Number(item.priceBlack) || 0)),
            priceCash: Math.max(0, Math.floor(Number(item.priceCash) || 0)),
            max,
            defaultAmount,
            image: item.image,
        };
    });
}

function openShop(data) {
    state.shop = data.shop === 'gps' ? 'gps' : 'dealer';
    state.items = sanitizeItems(data.items);
    state.itemMap = {};
    state.items.forEach((item) => { state.itemMap[item.item] = item; });
    state.categories = data.categories || [];
    state.category = 'all';
    state.search = '';
    state.method = 'black_money';
    state.cart = [];
    state.qty = {};
    state.buying = false;

    $('shop-title').textContent = data.title || 'Black Market';
    $('shop-location').textContent = data.location || data.subtitle || 'Mount Chiliad';

    const player = data.player || { name: 'Customer', role: 'Customer' };
    $('player-name').textContent = player.name || 'Customer';
    $('player-role').textContent = player.role || 'Customer';
    $('player-avatar').textContent = initials(player.name);

    $('search').value = '';
    setMoney(data.money || { cash: 0, black_money: 0 });
    setMethod('black_money');
    renderCategories();
    renderGrid();
    renderCart();
    $('app').classList.remove('hidden');
}

$('grid').addEventListener('click', (event) => {
    const btn = event.target.closest('[data-act]');
    if (!btn) return;
    const card = btn.closest('[data-item]');
    if (!card) return;
    const item = state.itemMap[card.dataset.item];
    if (!item) return;
    if (btn.dataset.act === 'minus') changeQty(item, -1);
    if (btn.dataset.act === 'plus') changeQty(item, 1);
    if (btn.dataset.act === 'add') addToCart(item, btn);
});

$('cart-list').addEventListener('click', (event) => {
    const btn = event.target.closest('[data-remove]');
    if (!btn) return;
    removeFromCart(btn.dataset.remove);
});

$('btn-close').addEventListener('click', closeUi);
$('btn-checkout').addEventListener('click', checkout);
$('pay-black').addEventListener('click', () => setMethod('black_money'));
$('pay-cash').addEventListener('click', () => setMethod('cash'));
$('search').addEventListener('input', (event) => {
    clearTimeout(searchTimer);
    searchTimer = setTimeout(() => {
        state.search = event.target.value.slice(0, 40);
        renderGrid();
    }, 80);
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
    openShop(demoCatalog);
}
