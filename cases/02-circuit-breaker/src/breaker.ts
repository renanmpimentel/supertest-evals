export interface Gateway {
  charge(amountCents: number): Promise<string>;
}

export type ChargeResult =
  | { ok: true; chargeId: string }
  | { ok: false; message: string };

export const FALLBACK_MESSAGE = "Payment gateway unavailable";

export class GatewayBreaker {
  private failures = 0;

  constructor(
    private readonly gateway: Gateway,
    private readonly threshold = 3,
  ) {}

  isOpen(): boolean {
    return this.failures >= this.threshold;
  }

  async charge(amountCents: number): Promise<ChargeResult> {
    if (this.isOpen()) {
      return { ok: false, message: FALLBACK_MESSAGE };
    }
    try {
      const chargeId = await this.gateway.charge(amountCents);
      this.failures = 0;
      return { ok: true, chargeId };
    } catch (error) {
      this.failures += 1;
      return { ok: false, message: (error as Error).message };
    }
  }
}
