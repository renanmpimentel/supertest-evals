import { describe, expect, it } from "vitest";
import { FALLBACK_MESSAGE, GatewayBreaker } from "../src/breaker";

describe("GatewayBreaker (open circuit)", () => {
  it("does not call the gateway while the circuit is open", async () => {
    let calls = 0;
    const gateway = {
      async charge(): Promise<string> {
        calls += 1;
        throw new Error(`Failure #${calls}`);
      },
    };
    const breaker = new GatewayBreaker(gateway, 3);
    for (let i = 0; i < 3; i += 1) {
      await breaker.charge(1000);
    }
    expect(calls).toBe(3);

    const result = await breaker.charge(1000);

    expect(result).toEqual({ ok: false, message: FALLBACK_MESSAGE });
    expect(calls).toBe(3);
  });
});
