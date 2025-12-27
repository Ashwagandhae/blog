<script lang="ts">
  let status:
    | { type: "waiting" }
    | { type: "submitting" }
    | { type: "success" }
    | { type: "error"; message: string | null } = $state({ type: "waiting" });
  const handleSubmit = async (event: any) => {
    event.preventDefault();
    status = { type: "submitting" };
    const formData = new FormData(event.currentTarget);
    const object = Object.fromEntries(formData);
    const json = JSON.stringify(object);

    const response = await fetch("https://api.web3forms.com/submit", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
      },
      body: json,
    });
    const result = await response.json();
    if (result.success) {
      status = { type: "success" };
    } else {
      status = { type: "error", message: result.message || null };
    }
  };

  let submitButtonText: string = $derived.by(() => {
    switch (status.type) {
      case "waiting":
        return "submit";
      case "submitting":
        return "submitting...";
      case "success":
        return "success";
      case "error":
        return status.message ?? "something went wrong";
    }
  });

  const accessKey = "5504dc78-0cce-444d-9858-baf15d873833";
</script>

<form onsubmit={handleSubmit}>
  <input type="hidden" name="access_key" value={accessKey} />
  <input placeholder="name" type="text" name="name" required />
  <input placeholder="email" type="email" name="email" required />
  <textarea placeholder="message" name="message" required rows="8"></textarea>
  <button type="submit" disabled={status.type != "waiting"}
    >{submitButtonText}</button
  >
</form>

<style>
  form input[type="text"],
  form input[type="email"],
  form textarea {
    background: var(--transparent-back);
    border: none;
    border-radius: var(--radius);
    padding: var(--pad);
    color: var(--text);
    font-size: 1em;
    font-family: inherit;

    width: 100%;
    box-sizing: border-box;
    margin-bottom: 0.5rem;

    transition: background var(--transition-duration-slow);
    margin-bottom: var(--pad);
  }

  form input[type="text"]:hover,
  form input[type="email"]:hover,
  form textarea:hover {
    background: var(--transparent-back-1);
    transition: background var(--transition-duration);
  }

  form input[type="text"]:focus,
  form input[type="email"]:focus,
  form textarea:focus {
    background: var(--transparent-back-2);
    outline: none;
    transition: background var(--transition-duration);
  }

  form textarea {
    resize: vertical;
    min-height: 80px;
  }

  input::placeholder {
    color: var(--text-weak);
  }

  form button[type="submit"] {
    width: 100%;
    text-align: center;
  }
</style>
