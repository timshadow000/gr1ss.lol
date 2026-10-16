(function () {
    'use strict';

    var SCRIPT_URL = 'https://gr1ss.js.org/0';
    var copyBtn = document.getElementById('copyBtn');
    var toast = document.getElementById('toast');

    function doCopy() {
        var text = 'loadstring(game:HttpGet("' + SCRIPT_URL + '"))()';
        function done() {
            copyBtn.textContent = 'copied';
            copyBtn.classList.add('ok');
            toast.classList.add('show');
            setTimeout(function () {
                copyBtn.textContent = 'copy';
                copyBtn.classList.remove('ok');
                toast.classList.remove('show');
            }, 1900);
        }
        function fallback() {
            var ta = document.createElement('textarea');
            ta.value = text;
            ta.style.position = 'fixed';
            ta.style.opacity = '0';
            document.body.appendChild(ta);
            ta.select();
            try { document.execCommand('copy'); } catch (e) {}
            document.body.removeChild(ta);
            done();
        }
        if (navigator.clipboard && navigator.clipboard.writeText) {
            navigator.clipboard.writeText(text).then(done).catch(fallback);
        } else {
            fallback();
        }
    }
    if (copyBtn) copyBtn.addEventListener('click', doCopy);

    var prog = document.getElementById('prog');
    var nav = document.getElementById('nav');
    function onScroll() {
        var h = document.documentElement;
        var pct = h.scrollTop / (h.scrollHeight - h.clientHeight);
        if (prog) prog.style.width = (pct * 100) + '%';
        if (nav) {
            if (h.scrollTop > 60) nav.classList.add('small');
            else nav.classList.remove('small');
        }
    }
    window.addEventListener('scroll', onScroll, { passive: true });

    var cur = document.getElementById('cur');
    var ring = document.getElementById('curRing');
    var mx = 0, my = 0, rx = 0, ry = 0;
    document.addEventListener('mousemove', function (e) {
        mx = e.clientX;
        my = e.clientY;
        if (cur) {
            cur.style.left = mx + 'px';
            cur.style.top = my + 'px';
        }
    });
    function ringLoop() {
        rx += (mx - rx) * 0.15;
        ry += (my - ry) * 0.15;
        if (ring) {
            ring.style.left = rx + 'px';
            ring.style.top = ry + 'px';
        }
        requestAnimationFrame(ringLoop);
    }
    ringLoop();

    var hoverables = 'a, button, summary, .t, .b, .step, .exec, .q';
    document.querySelectorAll(hoverables).forEach(function (el) {
        el.addEventListener('mouseenter', function () { document.body.classList.add('hover-link'); });
        el.addEventListener('mouseleave', function () { document.body.classList.remove('hover-link'); });
    });

    var sparkles = document.getElementById('sparkles');
    if (sparkles) {
        for (var i = 0; i < 40; i++) {
            var s = document.createElement('div');
            s.className = 'spark';
            s.style.left = Math.random() * 100 + '%';
            s.style.top = Math.random() * 100 + '%';
            s.style.animationDelay = (Math.random() * 3) + 's';
            s.style.animationDuration = (2 + Math.random() * 2) + 's';
            sparkles.appendChild(s);
        }
    }

    var counters = document.querySelectorAll('[data-count]');
    var counted = new WeakSet();
    function animateCounter(el) {
        if (counted.has(el)) return;
        counted.add(el);
        var target = parseInt(el.getAttribute('data-count'), 10);
        var suffix = el.getAttribute('data-suffix') || '';
        var start = performance.now();
        var dur = 1400;
        function step(t) {
            var p = Math.min(1, (t - start) / dur);
            var eased = 1 - Math.pow(1 - p, 3);
            el.textContent = Math.floor(target * eased) + suffix;
            if (p < 1) requestAnimationFrame(step);
            else el.textContent = target + suffix;
        }
        requestAnimationFrame(step);
    }

    document.querySelectorAll('.b').forEach(function (el) {
        el.addEventListener('mousemove', function (e) {
            var r = el.getBoundingClientRect();
            var x = e.clientX - r.left;
            var y = e.clientY - r.top;
            el.style.setProperty('--mx', x + 'px');
            el.style.setProperty('--my', y + 'px');
            var tiltX = ((y / r.height) - 0.5) * -6;
            var tiltY = ((x / r.width) - 0.5) * 6;
            el.style.transform = 'perspective(1000px) rotateX(' + tiltX + 'deg) rotateY(' + tiltY + 'deg) translateY(-4px)';
        });
        el.addEventListener('mouseleave', function () {
            el.style.transform = '';
        });
    });

    var shotWrap = document.getElementById('shotWrap');
    var shot = document.getElementById('shot');
    if (shotWrap && shot) {
        shotWrap.addEventListener('mousemove', function (e) {
            var r = shotWrap.getBoundingClientRect();
            var x = ((e.clientX - r.left) / r.width - 0.5) * 2;
            var y = ((e.clientY - r.top) / r.height - 0.5) * 2;
            shot.style.transform = 'perspective(1200px) rotateX(' + (-y * 3) + 'deg) rotateY(' + (x * 3) + 'deg) translateY(-4px)';
        });
        shotWrap.addEventListener('mouseleave', function () {
            shot.style.transform = '';
        });
    }

    document.querySelectorAll('[data-rip]').forEach(function (el) {
        el.addEventListener('click', function (e) {
            var r = el.getBoundingClientRect();
            var rip = document.createElement('span');
            rip.className = 'ripple';
            var size = Math.max(r.width, r.height);
            rip.style.width = size + 'px';
            rip.style.height = size + 'px';
            rip.style.left = (e.clientX - r.left - size / 2) + 'px';
            rip.style.top = (e.clientY - r.top - size / 2) + 'px';
            el.appendChild(rip);
            setTimeout(function () { rip.remove(); }, 600);
        });
    });

    var revealIO = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
            if (!entry.isIntersecting) return;
            entry.target.classList.add('on');
            revealIO.unobserve(entry.target);
        });
    }, { threshold: 0.08, rootMargin: '0px 0px -40px 0px' });
    document.querySelectorAll('.rv').forEach(function (el) { revealIO.observe(el); });

    function stagger(selector, base) {
        var els = document.querySelectorAll(selector);
        var io = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (!entry.isIntersecting) return;
                var idx = Array.prototype.indexOf.call(els, entry.target);
                entry.target.style.transitionDelay = (base + idx * 0.05) + 's';
                entry.target.classList.add('on');
                io.unobserve(entry.target);
            });
        }, { threshold: 0.08 });
        els.forEach(function (el) { io.observe(el); });
    }
    stagger('.b', 0);
    stagger('.t', 0);
    stagger('.step', 0);
    stagger('.q', 0);

    var counterIO = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
            if (entry.isIntersecting) {
                animateCounter(entry.target);
                counterIO.unobserve(entry.target);
            }
        });
    }, { threshold: 0.5 });
    counters.forEach(function (el) { counterIO.observe(el); });

    document.querySelectorAll('a[href^="#"]').forEach(function (a) {
        a.addEventListener('click', function (e) {
            e.preventDefault();
            var t = document.querySelector(a.getAttribute('href'));
            if (t) {
                var y = t.getBoundingClientRect().top + window.pageYOffset - 100;
                window.scrollTo({ top: y, behavior: 'smooth' });
            }
        });
    });
})();
