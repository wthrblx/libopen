declare class Trait<Parameters extends unknown[], Returns extends unknown[]> {
	readonly name: string;

	constructor(name: string);

	static isTrait(object: unknown): object is Trait<unknown[], unknown[]>;

	implement(object: unknown, implementation: (...parameters: Parameters) => LuaTuple<Returns>): void;
	unimplement(object: unknown): Maybe<(...parameters: Parameters) => LuaTuple<Returns>>;
	unimplementAll(): void;
	isImplemented(object: unknown): boolean;
	get(object: unknown): (...parameters: Parameters) => LuaTuple<Returns>;
	tryGet(object: unknown): Maybe<(...parameters: Parameters) => LuaTuple<Returns>>;
	call(object: unknown, ...parameters: Parameters): LuaTuple<Returns>;
	tryCall(object: unknown, ...parameters: Parameters): LuaTuple<[true, ...Parameters] | [false]>;
}

export = Trait;
