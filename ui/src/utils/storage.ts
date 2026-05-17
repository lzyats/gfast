import Cookies from 'js-cookie';

const tokenKeyBase = import.meta.env.VITE_TOKEN_KEY || 'token';
const tokenKeyPort = window.location.port || (window.location.protocol === 'https:' ? '443' : '80');
const tokenKey = `${tokenKeyBase}_${tokenKeyPort}`;

/**
 * window.localStorage 浏览器永久缓存
 * @method set 设置永久缓存
 * @method get 获取永久缓存
 * @method remove 移除永久缓存
 * @method clear 移除全部永久缓存
 */
export const Local = {
	// 设置永久缓存
	set(key: string, val: any) {
		window.localStorage.setItem(key, JSON.stringify(val));
	},
	// 获取永久缓存
	get(key: string) {
		let json: any = window.localStorage.getItem(key);
		return JSON.parse(json);
	},
	// 移除永久缓存
	remove(key: string) {
		window.localStorage.removeItem(key);
	},
	// 移除全部永久缓存
	clear() {
		window.localStorage.clear();
	},
};

/**
 * window.sessionStorage 浏览器临时缓存
 * @method set 设置临时缓存
 * @method get 获取临时缓存
 * @method remove 移除临时缓存
 * @method clear 移除全部临时缓存
 */
export const Session = {
	// 设置临时缓存
	set(key: string, val: any) {
		if (key === 'token') return Cookies.set(tokenKey, val);
		window.sessionStorage.setItem(key, JSON.stringify(val));
	},
	// 获取临时缓存
	get(key: string) {
		if (key === 'token') return Cookies.get(tokenKey);
		let json: any = window.sessionStorage.getItem(key);
		return JSON.parse(json);
	},
	// 移除临时缓存
	remove(key: string) {
		if (key === 'token') {
			Cookies.remove(tokenKey);
			Cookies.remove('token');
			return;
		}
		window.sessionStorage.removeItem(key);
	},
	// 移除全部临时缓存
	clear() {
		Cookies.remove(tokenKey);
		Cookies.remove('token');
		window.sessionStorage.clear();
	},
};
