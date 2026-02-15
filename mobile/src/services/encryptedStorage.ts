import * as SecureStore from "expo-secure-store";
import CryptoJS from "crypto-js";

const KEY_NAME = "nutriwalk_aes_key_v1";
const STORE_PREFIX = "nutriwalk_store_";

async function getOrCreateKey(): Promise<string> {
  const existing = await SecureStore.getItemAsync(KEY_NAME);
  if (existing) return existing;

  const bytes = CryptoJS.lib.WordArray.random(32);
  const key = CryptoJS.enc.Base64.stringify(bytes);
  await SecureStore.setItemAsync(KEY_NAME, key, { keychainAccessible: SecureStore.AFTER_FIRST_UNLOCK });
  return key;
}

export async function setEncryptedJSON<T>(key: string, value: T): Promise<void> {
  const aesKey = await getOrCreateKey();
  const json = JSON.stringify(value);
  const cipher = CryptoJS.AES.encrypt(json, aesKey).toString();
  await SecureStore.setItemAsync(STORE_PREFIX + key, cipher, { keychainAccessible: SecureStore.AFTER_FIRST_UNLOCK });
}

export async function getEncryptedJSON<T>(key: string, fallback: T): Promise<T> {
  const aesKey = await getOrCreateKey();
  const cipher = await SecureStore.getItemAsync(STORE_PREFIX + key);
  if (!cipher) return fallback;

  try {
    const bytes = CryptoJS.AES.decrypt(cipher, aesKey);
    const json = bytes.toString(CryptoJS.enc.Utf8);
    if (!json) return fallback;
    return JSON.parse(json) as T;
  } catch {
    return fallback;
  }
}

export async function deleteEncryptedKey(key: string): Promise<void> {
  await SecureStore.deleteItemAsync(STORE_PREFIX + key);
}
