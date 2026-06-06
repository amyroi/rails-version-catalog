export function normalizeCompareKeys(input: string | string[] | undefined, knownKeys: string[]) {
  const rawKeys = Array.isArray(input) ? input : input?.split(",") ?? knownKeys;
  const selectedKeys = rawKeys.map((key) => key.trim()).filter((key) => knownKeys.includes(key));
  return selectedKeys.length > 0 ? selectedKeys : knownKeys;
}
