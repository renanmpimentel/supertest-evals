import { describe, expect, it } from "vitest";
import { FALLBACK_MESSAGE, GatewayBreaker } from "../src/breaker";

const unavailable = {
  async charge(): Promise<string> {
    throw new Error("Payment gateway unavailable");
  },
};

describe("GatewayBreaker", () => {
  it("returns the charge id when the gateway succeeds", async () => {
    const breaker = new GatewayBreaker({ charge: async () => "ch_1" }, 3);
    expect(await breaker.charge(1000)).toEqual({ ok: true, chargeId: "ch_1" });
  });

  it("returns the fallback once the circuit is open", async () => {
    const breaker = new GatewayBreaker(unavailable, 3);
    for (let i = 0; i < 3; i += 1) {
      await breaker.charge(1000);
    }
    expect(breaker.isOpen()).toBe(true);
    const result = await breaker.charge(1000);
    expect(result).toEqual({ ok: false, message: FALLBACK_MESSAGE });
  });
});
