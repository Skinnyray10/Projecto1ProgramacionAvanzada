export function success(res, data, status = 200) {
  return res.status(status).json({ ok: true, data });
}

export function fail(res, message, status = 400, details) {
  const payload = { ok: false, error: message };
  if (details) payload.details = details;
  return res.status(status).json(payload);
}

export function asyncHandler(fn) {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}
