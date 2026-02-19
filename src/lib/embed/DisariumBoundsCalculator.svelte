<script lang="ts">
  let numDigits: number = $state(5);
  let frozenDigits: string = $state("89");

  function disarium(num: string): bigint {
    let digitStr = num.toString();
    let digits = Array.from(digitStr).map((digit) => BigInt(digit));
    let sum = BigInt(0);
    for (let i = 0; i < digits.length; i++) {
      sum += digits[i] ** BigInt(i + 1);
    }
    return sum;
  }

  let boundDigits:
    | { type: "error"; message: string }
    | {
        type: "success";
        minDigits: bigint;
        maxDigits: bigint;
        minSum: bigint;
        maxSum: bigint;
        originalCheckCount: bigint;
        finalCheckCount: bigint;
      } = $derived.by(() => {
    let isOnlyDigits = /^\d+$/.test(frozenDigits);
    if (!isOnlyDigits)
      return {
        type: "error",
        message: "frozen digits contains non-digit characters",
      };
    if (frozenDigits.length > numDigits) {
      return {
        type: "error",
        message: "frozen digits length is larger than num digits",
      };
    }
    let minDigits = frozenDigits;
    let maxDigits = frozenDigits;
    let first = true;
    while (minDigits.length < numDigits) {
      minDigits = "0" + minDigits;
      maxDigits = "9" + maxDigits;
      first = false;
    }

    if (minDigits.startsWith("0")) {
      minDigits = "1" + minDigits.slice(1);
    }

    let minSum = disarium(minDigits);
    let maxSum = disarium(maxDigits);

    let originalCheckCount =
      numDigits == frozenDigits.length
        ? BigInt(1)
        : BigInt(10) ** BigInt(numDigits - frozenDigits.length - 1) * BigInt(9);

    let minBound = minSum;
    if (BigInt(minDigits) > minSum) {
      minBound = BigInt(minDigits);
    }
    let maxBound = maxSum;
    if (BigInt(maxDigits) < maxSum) {
      maxBound = BigInt(maxDigits);
    }
    let finalCheckCount =
      BigInt(maxBound.toString()) / BigInt(10) ** BigInt(frozenDigits.length) -
      BigInt(minBound.toString()) / BigInt(10) ** BigInt(frozenDigits.length);
    if (finalCheckCount < 0) {
      finalCheckCount = BigInt(0);
    }

    return {
      type: "success",
      minDigits: BigInt(minDigits),
      maxDigits: BigInt(maxDigits),
      minSum,
      maxSum,
      originalCheckCount,
      finalCheckCount,
    };
  });
</script>

<div class="top">
  <div class="row">
    <label for="digits">number of digits</label>
    <input
      type="range"
      placeholder="number of digits"
      name="digits"
      min="1"
      max="22"
      bind:value={numDigits}
    />
    <input
      type="text"
      inputmode="numeric"
      min="1"
      max="22"
      bind:value={numDigits}
    />
  </div>

  <div class="row">
    <label for="digits">frozen digits</label>
    <input type="text" bind:value={frozenDigits} />
  </div>
</div>
<div class="top">
  <div class="out">
    {#if boundDigits.type == "error"}
      <p>
        error: {boundDigits.message}
      </p>
    {:else}
      <p>
        min digits: {boundDigits.minDigits} with digit-power-sum of {boundDigits.minSum}
      </p>

      <p>
        max digits: {boundDigits.maxDigits} with digit-power-sum of {boundDigits.maxSum}
      </p>

      <p>
        original check count: {boundDigits.originalCheckCount}
      </p>
      <p>
        new check count: {boundDigits.finalCheckCount}
      </p>
      <p>
        fraction of original: {Number(boundDigits.finalCheckCount) /
          Number(boundDigits.originalCheckCount)}
      </p>
    {/if}
  </div>
</div>

<style>
  .top {
    background: var(--transparent-back);
    padding: var(--pad);
    border-radius: var(--radius);
    display: flex;
    flex-direction: column;
    margin: var(--pad) 0;
    gap: var(--pad);
  }
  .row {
    display: flex;
    flex-direction: row;
    align-items: center;
    flex-wrap: wrap;
    gap: var(--pad);
  }
</style>
